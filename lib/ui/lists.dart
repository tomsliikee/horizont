import 'package:material_ui/material_ui.dart';

import '../theme/extensions.dart';
import '../theme/type.dart';
import 'buttons.dart';
import 'squish.dart';

/// A square well, 40 by 40 with radius 12, holding an icon (a tone pair).
class IconWell extends StatelessWidget {
  const IconWell({
    super.key,
    required this.icon,
    this.fill,
    this.ink,
    this.size = 40,
  });

  final IconData icon;
  final Color? fill;
  final Color? ink;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill ?? scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(HorizontRadii.of(context).medium),
      ),
      alignment: Alignment.center,
      child: SymbolIcon(icon, size: 20, color: ink ?? scheme.onSurfaceVariant),
    );
  }
}

/// A letter standing in for a favicon (D12), on a well.
class Monogram extends StatelessWidget {
  const Monogram(this.letter, {super.key, this.size = 40, this.radius = 12});

  final String letter;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: HorizontType.monogram.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

/// One row of a [ListGroup]: leading, title with subtitle, trailing.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.minHeight = 64,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double minHeight;
  final BorderRadius borderRadius;

  /// This row with the corners the group assigns it.
  ListRow withRadius(BorderRadius radius) => ListRow(
    key: key,
    leading: leading,
    title: title,
    subtitle: subtitle,
    trailing: trailing,
    onTap: onTap,
    minHeight: minHeight,
    borderRadius: radius,
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final row = Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceBright,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 16)],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: HorizontType.bodyMedium.copyWith(
                    color: scheme.onSurface,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: HorizontType.caption.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 16), trailing!],
        ],
      ),
    );
    return onTap == null
        ? row
        : Squish(
            onTap: onTap,
            semanticLabel: title,
            pressedScale: 0.97,
            child: row,
          );
  }
}

/// Rows 4 px apart; outer corners 24, inner 8 (`radius()` in the prototype).
class ListGroup extends StatelessWidget {
  const ListGroup({super.key, required this.rows});

  final List<ListRow> rows;

  @override
  Widget build(BuildContext context) {
    final radii = HorizontRadii.of(context);
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          rows[i].withRadius(radii.groupItem(i, rows.length)),
        ],
      ],
    );
  }
}
