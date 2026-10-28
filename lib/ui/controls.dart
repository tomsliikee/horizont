import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../theme/motion.dart';
import '../theme/type.dart';
import 'haptics.dart';
import 'squish.dart';

/// The switch of the prototype: a 52 by 32 track; the knob grows from 16 to
/// 24 as it travels (P:768).
class HorizontSwitch extends StatelessWidget {
  const HorizontSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      toggled: value,
      label: semanticLabel,
      child: Squish(
        pressedScale: 0.94,
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: SingleMotionBuilder(
          value: value ? 1 : 0,
          motion: HorizontMotion.spatialFor(
            context,
            HorizontMotion.spatialFast,
          ),
          builder: (context, raw, _) {
            // The spring may overshoot; colours must stay valid.
            final colour = raw.clamp(0.0, 1.0);
            return Container(
              width: 52,
              height: 32,
              decoration: BoxDecoration(
                color: Color.lerp(
                  scheme.surfaceContainerHighest,
                  scheme.primary,
                  colour,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  width: 2,
                  color: Color.lerp(scheme.outline, scheme.primary, colour)!,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: lerpDouble(6, 22, raw),
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        width: lerpDouble(16, 24, colour),
                        height: lerpDouble(16, 24, colour),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.lerp(
                            scheme.outline,
                            scheme.onPrimary,
                            colour,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Connected buttons 2 px apart: ends pill-rounded on the outside and 8
/// inside; the selected one becomes a full pill in `primary` and its label
/// goes 500 to 800 (P:394).
class SegmentRow extends StatelessWidget {
  const SegmentRow({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.height = 48,
    this.icons,
    this.fill,
  });

  final List<String> labels;

  /// An icon before each label (the library's tabs, the theme modes).
  final List<IconData>? icons;

  /// The unselected fill; `primaryContainer` by default.
  final Color? fill;
  final int selected;
  final ValueChanged<int> onSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final motion = HorizontMotion.spatialFor(
      context,
      HorizontMotion.spatialFast,
    );
    final full = height / 2;
    return Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            child: Squish(
              pressedScale: 0.96,
              haptic: false,
              onTap: () {
                if (i != selected) Haptics.play(Haptic.tick);
                onSelected(i);
              },
              child: SingleMotionBuilder(
                value: i == selected ? 1 : 0,
                motion: motion,
                builder: (context, raw, _) {
                  final t = raw.clamp(0.0, 1.0);
                  final first = i == 0;
                  final last = i == labels.length - 1;
                  Radius corner(bool outer) =>
                      Radius.circular(lerpDouble(outer ? full : 8, full, t)!);
                  return Container(
                    height: height,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        fill ?? scheme.primaryContainer,
                        scheme.primary,
                        t,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: corner(first),
                        bottomLeft: corner(first),
                        topRight: corner(last),
                        bottomRight: corner(last),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icons != null) ...[
                          Icon(
                            icons![i],
                            size: 20,
                            fill: t,
                            color: Color.lerp(
                              fill == null
                                  ? scheme.onPrimaryContainer
                                  : scheme.onSurfaceVariant,
                              scheme.onPrimary,
                              t,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            labels[i],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: HorizontType.navLabel(t).copyWith(
                              color: Color.lerp(
                                fill == null
                                    ? scheme.onPrimaryContainer
                                    : scheme.onSurfaceVariant,
                                scheme.onPrimary,
                                t,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}
