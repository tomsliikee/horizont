import 'package:material_ui/material_ui.dart';

import '../theme/type.dart';
import 'buttons.dart';
import 'progress_line.dart';
import 'squish.dart';

/// The address in a bar: a lock or search icon and the domain, with the
/// page-load progress as a thin line along its bottom edge. A tap anywhere on
/// it opens the search; a long press does [onLongPress] (copies the address).
class AddressPill extends StatelessWidget {
  const AddressPill({
    super.key,
    required this.text,
    required this.placeholder,
    required this.secure,
    required this.onTap,
    this.onLongPress,
    this.progress,
    this.height = 48,
    this.small = false,
    this.centered = true,
    this.icon,
    this.iconColor,
  });

  /// The domain; empty on the start page, where [placeholder] shows.
  final String text;
  final String placeholder;
  final bool secure;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// 0 to 1 while a page loads; null when idle.
  final double? progress;
  final double height;

  /// The 13/18 text of the minimal bar.
  final bool small;
  final bool centered;

  /// Overrides the lock or search icon (private mode).
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final empty = text.isEmpty;
    final style = small ? HorizontType.addressSmall : HorizontType.address;
    return Squish(
      onTap: onTap,
      onLongPress: onLongPress,
      semanticLabel: empty ? placeholder : text,
      pressedScale: 0.97,
      child: SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: centered
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: [
                  SymbolIcon(
                    icon ?? (secure && !empty ? HIcons.lock : HIcons.search),
                    size: small ? 14 : 16,
                    color: iconColor ?? scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      empty ? placeholder : text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style.copyWith(
                        color: empty
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 0,
              child: ProgressLine(progress: progress),
            ),
          ],
        ),
      ),
    );
  }
}
