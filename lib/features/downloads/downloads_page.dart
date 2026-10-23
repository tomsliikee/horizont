import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:material_ui/material_ui.dart';

import '../../app/system_ui.dart';
import '../../browser/tabs/tabs_notifier.dart';
import '../../data/library.dart';
import '../../data/library_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../platform/downloads_service.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/cards.dart';
import '../../ui/lists.dart';
import '../../ui/motion/count_up.dart';
import '../../ui/motion/staggered.dart';
import '../../ui/tiles.dart';

/// "12,4 MB" in the language of [context].
String fileSize(int bytes, BuildContext context) {
  final locale = Localizations.localeOf(context).toString();
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1000 && unit < units.length - 1) {
    value /= 1000;
    unit++;
  }
  final digits = unit == 0 || value >= 100 ? 0 : 1;
  return '${NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: digits).format(value)} ${units[unit]}';
}

/// The downloads screen (`P:450`–`P:493`): the running download and today's
/// total as tiles, then the list by day.
class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final items = ref.watch(downloadsProvider).value ?? const <DownloadItem>[];
    final service = ref.watch(downloadsServiceProvider);
    final now = ref.read(clockProvider)();
    final locale = Localizations.localeOf(context).toString();

    return SystemUiRegion(
      child: Scaffold(
        backgroundColor: scheme.surfaceContainer,
        body: StatusBand(
          child: ValueListenableBuilder<Map<String, LiveProgress>>(
            valueListenable: service.progress,
            builder: (context, live, _) {
              final running = items.where((d) => d.active).toList();
              final first = running.firstOrNull;
              final today = items
                  .where((d) => _sameDay(d.startedAt, now))
                  .toList();
              final todayBytes = today.fold<int>(
                0,
                (sum, d) => sum + (d.totalBytes ?? d.receivedBytes),
              );
              final groups = <String, List<DownloadItem>>{};
              for (final d in items) {
                groups
                    .putIfAbsent(
                      _dayLabel(d.startedAt, now, l10n, locale),
                      () => [],
                    )
                    .add(d);
              }
              final firstLive = first == null ? null : live[first.taskId];
              final percent = firstLive == null || firstLive.fraction < 0
                  ? (first?.fraction ?? 0) * 100
                  : firstLive.fraction * 100;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: ScreenHeader(
                      title: l10n.downloads,
                      subtitle: l10n.savedInDownload,
                      backLabel: l10n.back,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    sliver: SliverToBoxAdapter(
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: 12,
                          children: [
                            Expanded(
                              child: StatTile(
                                loud: true,
                                metric: first == null
                                    ? Text(
                                        '0',
                                        style: HorizontType.metricL.copyWith(
                                          color: scheme.onPrimaryContainer,
                                        ),
                                      )
                                    : CountUp(
                                        value: percent.round(),
                                        format: (v) => '$v %',
                                        style: HorizontType.metricL.copyWith(
                                          color: scheme.onPrimaryContainer,
                                        ),
                                      ),
                                label: first?.fileName ?? l10n.nothingRunning,
                                strong: first == null
                                    ? l10n.allDone
                                    : firstLive?.remaining == null
                                    ? null
                                    : l10n.timeRemaining(
                                        _duration(
                                          firstLive!.remaining!,
                                          locale,
                                        ),
                                      ),
                              ),
                            ),
                            Expanded(
                              child: StatTile(
                                metric: Text(fileSize(todayBytes, context)),
                                label: l10n.filesToday(today.length),
                                aside: running.isEmpty
                                    ? null
                                    : l10n.includingRunning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (items.isEmpty)
                    SliverToBoxAdapter(
                      child: EmptyState(
                        icon: HIcons.download,
                        title: l10n.noDownloads,
                        hint: l10n.noDownloadsHint,
                      ),
                    ),
                  for (final entry in groups.entries) ...[
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: SectionHeader(entry.key),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          spacing: 4,
                          children: [
                            for (var i = 0; i < entry.value.length; i++)
                              StaggeredEntrance(
                                key: ValueKey(entry.value[i].taskId),
                                index: i,
                                child: _DownloadRow(
                                  item: entry.value[i],
                                  live: live[entry.value[i].taskId],
                                  radius: GroupRadius.of(
                                    context,
                                    i,
                                    entry.value.length,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (items.any((d) => !d.active))
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: PillButton(
                          label: l10n.clearList,
                          height: 52,
                          onTap: () => unawaited(
                            ref.read(libraryProvider).clearDownloads(),
                          ),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewPaddingOf(context).bottom + 48,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dayLabel(
    DateTime at,
    DateTime now,
    AppLocalizations l10n,
    String locale,
  ) {
    if (_sameDay(at, now)) return l10n.today;
    if (_sameDay(at, now.subtract(const Duration(days: 1)))) {
      return l10n.yesterday;
    }
    return DateFormat.MMMMEEEEd(locale).format(at);
  }

  static String _duration(Duration d, String locale) {
    if (d.inMinutes >= 1) return '${d.inMinutes} min';
    return '${d.inSeconds.clamp(1, 59)} s';
  }
}

/// The corners of row [index] of [count] (`groupItem`).
abstract final class GroupRadius {
  static BorderRadius of(BuildContext context, int index, int count) {
    const big = Radius.circular(24);
    const small = Radius.circular(8);
    if (count == 1) return const BorderRadius.all(big);
    if (index == 0) return const BorderRadius.vertical(top: big, bottom: small);
    if (index == count - 1) {
      return const BorderRadius.vertical(top: small, bottom: big);
    }
    return const BorderRadius.all(small);
  }
}

class _DownloadRow extends ConsumerWidget {
  const _DownloadRow({
    required this.item,
    required this.live,
    required this.radius,
  });

  final DownloadItem item;
  final LiveProgress? live;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final service = ref.read(downloadsServiceProvider);
    final locale = Localizations.localeOf(context).toString();
    final (icon, fill, ink) = _look(item.mimeType, item.fileName, scheme);
    final total = live?.expectedBytes ?? item.totalBytes;
    final fraction = live != null && live!.fraction >= 0
        ? live!.fraction
        : item.fraction;
    final status = switch (item.status) {
      DownloadStatus.failed => l10n.downloadFailed,
      DownloadStatus.canceled => l10n.downloadCanceled,
      DownloadStatus.paused => l10n.downloadPaused,
      DownloadStatus.waiting => l10n.downloadWaiting,
      _ => null,
    };
    final sizeText = item.active && total != null && fraction != null
        ? l10n.sizeOf(
            fileSize((fraction * total).round(), context),
            fileSize(total, context),
          )
        : [
            if (total != null) fileSize(total, context),
            if (item.host.isNotEmpty) item.host,
            DateFormat.Hm(locale).format(item.finishedAt ?? item.startedAt),
          ].join(' · ');
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      decoration: BoxDecoration(
        color: scheme.surfaceBright,
        borderRadius: radius,
      ),
      child: Row(
        spacing: 16,
        children: [
          IconWell(
            icon: icon,
            fill: item.active ? scheme.primary : fill,
            ink: item.active ? scheme.onPrimary : ink,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  item.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HorizontType.bodyMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                if (item.active) LinearBar(value: fraction),
                Text(
                  status == null ? sizeText : '$status · $sizeText',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HorizontType.caption.copyWith(
                    color: item.status == DownloadStatus.failed
                        ? scheme.error
                        : scheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          if (item.status == DownloadStatus.running ||
              item.status == DownloadStatus.waiting)
            RoundButton(
              icon: HIcons.pause,
              semanticLabel: l10n.pauseDownload,
              size: 44,
              iconSize: 20,
              look: ButtonLook.highest,
              onTap: () => unawaited(service.pause(item.taskId)),
              onLongPress: () => unawaited(service.cancel(item.taskId)),
            )
          else if (item.status == DownloadStatus.paused)
            RoundButton(
              icon: HIcons.playArrow,
              semanticLabel: l10n.resumeDownload,
              size: 44,
              iconSize: 20,
              look: ButtonLook.primary,
              onTap: () => unawaited(service.resume(item.taskId)),
              onLongPress: () => unawaited(service.cancel(item.taskId)),
            )
          else if (item.status == DownloadStatus.done)
            RoundButton(
              icon: HIcons.folderOpen,
              semanticLabel: l10n.openFile,
              size: 44,
              iconSize: 20,
              look: ButtonLook.plain,
              onTap: () async {
                final ok = await service.open(item);
                if (!ok && context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(l10n.openFailed)));
                }
              },
            )
          else
            RoundButton(
              icon: HIcons.close,
              semanticLabel: l10n.remove,
              size: 44,
              iconSize: 20,
              look: ButtonLook.plain,
              onTap: () => unawaited(
                ref.read(libraryProvider).removeDownload(item.taskId),
              ),
            ),
        ],
      ),
    );
  }

  static (IconData, Color, Color) _look(
    String mime,
    String name,
    ColorScheme s,
  ) {
    final lower = name.toLowerCase();
    if (mime == 'application/pdf' || lower.endsWith('.pdf')) {
      return (HIcons.pictureAsPdf, s.primaryContainer, s.onPrimaryContainer);
    }
    if (mime.startsWith('image/')) {
      return (HIcons.image, s.tertiaryContainer, s.onTertiaryContainer);
    }
    if (mime.startsWith('video/')) {
      return (HIcons.videoFile, s.secondaryContainer, s.onSecondaryContainer);
    }
    if (mime.startsWith('audio/')) {
      return (HIcons.audioFile, s.secondaryContainer, s.onSecondaryContainer);
    }
    if (mime.contains('zip') || lower.endsWith('.zip')) {
      return (HIcons.folderZip, s.surfaceContainerHigh, s.onSurfaceVariant);
    }
    return (HIcons.fileIcon, s.surfaceContainerHigh, s.onSurfaceVariant);
  }
}
