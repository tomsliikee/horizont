import 'package:material_ui/material_ui.dart';

import '../theme/type.dart';
import 'buttons.dart';
import 'squish.dart';

/// The address in the middle of a bar: a lock or search icon and the domain,
/// centred, with the page-load progress as a thin line along its bottom edge.
/// A tap anywhere on it opens the search.
class AddressPill extends StatelessWidget {
  const AddressPill({
    super.key,
    required this.text,
    required this.placeholder,
    required this.secure,
    required this.onTap,
    this.progress,
    this.height = 48,
  });

  /// The domain; empty on the start page, where [placeholder] shows.
  final String text;
  final String placeholder;
  final bool secure;
  final VoidCallback onTap;

  /// 0 to 1 while a page loads; null when idle.
  final double? progress;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final empty = text.isEmpty;
    return Squish(
      onTap: onTap,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SymbolIcon(
                    secure && !empty ? HIcons.lock : HIcons.search,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      empty ? placeholder : text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: HorizontType.address.copyWith(
                        color: empty
                            ? scheme.onSurfaceVariant
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (progress != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1.5),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 3,
                    color: scheme.primary,
                    backgroundColor: const Color(0x00000000),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
