import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../theme/type.dart';
import 'buttons.dart';
import 'lists.dart';
import 'squish.dart';

/// A tab in the overview (`P:360`–`P:373`): a preview above a title strip,
/// with a ring when it is the one in front. It knows nothing about tabs, only
/// what it shows.
class TabCard extends StatelessWidget {
  const TabCard({
    super.key,
    required this.title,
    required this.letter,
    required this.closeLabel,
    required this.onTap,
    required this.onClose,
    this.active = false,
    this.pageColor,
    this.thumbnailPath,
    this.previewCacheWidth,
  });

  final String title;
  final String letter;
  final String closeLabel;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onClose;

  /// The colour at the top of the page, for the stand-in preview.
  final Color? pageColor;
  final String? thumbnailPath;

  /// Decode width in pixels, so a picture is not kept at full size.
  final int? previewCacheWidth;

  static const previewHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            spacing: 4,
            children: [
              Squish(
                onTap: onTap,
                semanticLabel: title,
                pressedScale: 0.96,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                    bottom: Radius.circular(8),
                  ),
                  child: SizedBox(
                    height: previewHeight,
                    width: double.infinity,
                    child: _Preview(
                      pageColor: pageColor,
                      thumbnailPath: thumbnailPath,
                      cacheWidth: previewCacheWidth,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 4, 2, 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceBright,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      // The strip opens the tab too, not only the preview.
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onTap,
                        child: Row(
                          spacing: 8,
                          children: [
                            Monogram(letter, size: 24, radius: 8),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: HorizontType.addressSmall.copyWith(
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    RoundButton(
                      icon: HIcons.close,
                      semanticLabel: closeLabel,
                      look: ButtonLook.plain,
                      size: 44,
                      iconSize: 18,
                      onTap: onClose,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // The ring: 3 px, 2 px off the card, outside its layout box.
          if (active)
            Positioned(
              left: -5,
              right: -5,
              top: -5,
              bottom: -5,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(31),
                    border: Border.all(color: scheme.primary, width: 3),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The picture of the page, or a stand-in: a band in the page colour and
/// three grey lines.
class _Preview extends StatelessWidget {
  const _Preview({this.pageColor, this.thumbnailPath, this.cacheWidth});

  final Color? pageColor;
  final String? thumbnailPath;
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget standIn() => ColoredBox(
      color: scheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 92, color: pageColor ?? scheme.primaryContainer),
          const SizedBox(height: 14),
          _line(context, 0.75, 10, scheme.onSurfaceVariant),
          const SizedBox(height: 8),
          _line(context, 0.60, 8, scheme.surfaceContainerHighest),
          const SizedBox(height: 8),
          _line(context, 0.68, 8, scheme.surfaceContainerHighest),
          const SizedBox(height: 8),
          _line(context, 0.40, 8, scheme.surfaceContainerHighest),
        ],
      ),
    );
    final path = thumbnailPath;
    if (path == null) return standIn();
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) => standIn(),
    );
  }

  Widget _line(BuildContext context, double fraction, double height, Color c) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: FractionallySizedBox(
          widthFactor: fraction,
          alignment: Alignment.centerLeft,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ),
      );
}
