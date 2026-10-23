import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../browser/browser_providers.dart';
import '../browser/tabs/tabs_notifier.dart';
import '../browser/web_engine.dart';
import '../data/library.dart';
import '../data/library_providers.dart';
import '../l10n/app_localizations.dart';
import '../platform/horizont_webkit.dart';
import '../theme/type.dart';
import '../ui/buttons.dart';
import '../ui/lists.dart';
import '../ui/tiles.dart';
import 'providers.dart';

/// What the menu and the bars do with the page in front. Every action shows
/// what it did in a snack bar of [messenger], which outlives the menu.
class PageActions {
  PageActions(this.ref, this.messenger);

  final WidgetRef ref;
  final ScaffoldMessengerState messenger;

  WebEngine get _engine => ref.read(webEngineProvider);
  PageState get _page => ref.read(pageStateProvider);
  Library get _library => ref.read(libraryProvider);

  void _say(String text, {SnackBarAction? action}) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          action: action,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> share() async {
    final url = _page.url;
    if (url == null) return;
    await HorizontWebKit.share(url.toString(), subject: _page.title);
  }

  /// Saves the page in the favourites, or removes it everywhere when it is
  /// saved already. The snack bar offers another folder.
  Future<void> toggleBookmark(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final url = _page.url;
    if (url == null) return;
    final existing = await _library.bookmarksOf(url);
    if (existing.isNotEmpty) {
      for (final b in existing) {
        await _library.removeBookmark(b.id);
      }
      _say(
        l10n.bookmarkRemoved,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () {
            for (final b in existing) {
              unawaited(_library.addBookmark(b.folderId, b.url, b.title));
            }
          },
        ),
      );
      return;
    }
    final folders = await _library.folders();
    final favourites = folders.firstWhere((f) => f.isFavorites);
    final id = await _library.addBookmark(favourites.id, url, _page.title);
    unawaited(HapticFeedback.lightImpact());
    if (!context.mounted) return;
    _say(
      l10n.bookmarkAdded(favourites.name),
      action: SnackBarAction(
        label: l10n.chooseFolder,
        onPressed: () => unawaited(_moveBookmark(context, id, url)),
      ),
    );
  }

  Future<void> _moveBookmark(BuildContext context, int id, Uri url) async {
    final folder = await pickFolder(context, ref);
    if (folder == null) return;
    await _library.removeBookmark(id);
    await _library.addBookmark(folder.id, url, _page.title);
  }

  /// Adds the page to the reading list with an offline copy and an estimate
  /// of the reading time (200 words a minute).
  Future<void> addToReadingList(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final url = _page.url;
    if (url == null) return;
    final info = await _engine.readPageInfo();
    final minutes = (info.words / 200).ceil().clamp(1, 600);
    await _library.addReading(
      url,
      _page.title,
      ref.read(clockProvider)(),
      minutes: minutes,
    );
    unawaited(HapticFeedback.lightImpact());
    final dir = await getApplicationSupportDirectory();
    final offline = Directory('${dir.path}/offline');
    await offline.create(recursive: true);
    final saved = await _engine.saveArchive(
      '${offline.path}/${url.toString().hashCode.toUnsigned(32)}.mht',
    );
    if (saved != null) await _library.updateReading(url, offlinePath: saved);
    _say(saved != null ? l10n.readingAddedOffline : l10n.readingAdded);
  }

  Future<void> setReader(BuildContext context, bool on) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final zoom = ref.read(settingsProvider).textZoomFor(_page.host);
    final ok = await _engine.setReader(
      on,
      style: ReaderStyle(
        background: scheme.surfaceContainerLowest,
        text: scheme.onSurface,
        muted: scheme.onSurfaceVariant,
        accent: scheme.primary,
        textZoom: zoom,
      ),
    );
    if (!ok && on) _say(l10n.noArticle);
  }

  Future<void> setTextZoom(int percent) async {
    final host = _page.host;
    if (host.isEmpty) return;
    ref
        .read(settingsProvider.notifier)
        .update((s) => s.withTextZoom(host, percent));
    await _engine.setTextZoom(percent);
  }

  Future<void> toggleDesktop() => _engine.setDesktopMode(!_page.desktop);

  Future<void> addToHomeScreen(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final url = _page.url;
    if (url == null) return;
    final title = _page.title.isEmpty ? _page.displayHost : _page.title;
    final ok = await HorizontWebKit.pinShortcut(
      url: url.toString(),
      title: title,
      letter: _page.displayHost.isEmpty
          ? '·'
          : _page.displayHost[0].toUpperCase(),
      background: scheme.primaryContainer.toARGB32(),
      foreground: scheme.onPrimaryContainer.toARGB32(),
    );
    if (!ok) _say(l10n.pinUnsupported);
  }

  void openPrivateTab() => ref.read(tabsProvider.notifier).open(private: true);

  void openNewTab() => ref.read(tabsProvider.notifier).open();
}

/// Lets the user pick a bookmark folder, or create one; null when dismissed.
Future<BookmarkFolder?> pickFolder(BuildContext context, WidgetRef ref) async {
  final library = ref.read(libraryProvider);
  final folders = await library.folders();
  if (!context.mounted) return null;
  return showModalBottomSheet<BookmarkFolder>(
    context: context,
    showDragHandle: false,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      final l10n = AppLocalizations.of(context);
      final scheme = Theme.of(context).colorScheme;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DragHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text(
                  l10n.chooseFolder,
                  style: HorizontType.title.copyWith(color: scheme.onSurface),
                ),
              ),
              ListGroup(
                rows: [
                  for (final f in folders)
                    ListRow(
                      leading: IconWell(icon: folderIcon(f.icon)),
                      title: f.name,
                      subtitle: l10n.bookmarkCount(f.count),
                      minHeight: 60,
                      onTap: () => Navigator.of(context).pop(f),
                    ),
                  ListRow(
                    leading: const IconWell(icon: HIcons.add),
                    title: l10n.newFolder,
                    minHeight: 60,
                    onTap: () async {
                      final name = await askText(
                        context,
                        title: l10n.newFolder,
                        label: l10n.folderName,
                        action: l10n.create,
                      );
                      if (name == null || name.trim().isEmpty) return;
                      final id = await library.createFolder(name.trim());
                      if (!context.mounted) return;
                      Navigator.of(context)
                          .pop(BookmarkFolder(id: id, name: name.trim()));
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

IconData folderIcon(FolderIcon icon) => switch (icon) {
  FolderIcon.star => HIcons.star,
  FolderIcon.school => HIcons.school,
  FolderIcon.hiking => HIcons.hiking,
  FolderIcon.restaurant => HIcons.restaurant,
  FolderIcon.bookmarks => HIcons.bookmarks,
  FolderIcon.folder => HIcons.folderOpen,
};

/// A small dialog with one text field; the text, or null when cancelled.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String label,
  required String action,
  String initial = '',
}) {
  final controller = TextEditingController(text: initial);
  final l10n = AppLocalizations.of(context);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(action),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

/// Asks before something that cannot be undone; true when confirmed.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  bool destructive = true,
}) async {
  final l10n = AppLocalizations.of(context);
  final scheme = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(action),
        ),
      ],
    ),
  );
  return result ?? false;
}
