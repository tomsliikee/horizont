import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

import '../../theme/motion.dart';
import '../../theme/type.dart';
import '../../ui/buttons.dart';
import '../../ui/horizont_logo.dart';
import '../../ui/motion/spring.dart';

/// The start page's head: greeting, logo and name, and the settings button.
/// Scrolled up it shrinks into a bar that stays at the top: the greeting
/// fades, the name gets smaller and the bar takes the page's colour.
class StartHeaderDelegate extends SliverPersistentHeaderDelegate {
  StartHeaderDelegate({
    required this.top,
    required this.greeting,
    required this.title,
    required this.settingsLabel,
    required this.onSettings,
  });

  /// The status bar and any bar at the top above the head.
  final double top;
  final String greeting;
  final String title;
  final String settingsLabel;
  final VoidCallback onSettings;

  static const _open = 116.0;
  static const _closed = 64.0;

  @override
  double get maxExtent => top + _open;

  @override
  double get minExtent => top + _closed;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    final scheme = Theme.of(context).colorScheme;
    final t = (shrinkOffset / (_open - _closed)).clamp(0.0, 1.0);
    final row = lerpDouble(4, 8, t)!;
    return ColoredBox(
      // The page's own background, so the bar is the page grown solid.
      color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: t),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            right: 72,
            top: top + 16 - 12 * t,
            child: Opacity(
              opacity: (1 - t * 2).clamp(0.0, 1.0),
              child: Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: HorizontType.subtitle.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: row,
            child: Row(
              spacing: lerpDouble(12, 10, t)!,
              children: [
                RisingLogo(size: lerpDouble(44, 36, t)!),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Transform.scale(
                      // 36 down to 22, the size of a bar's title.
                      scale: lerpDouble(1, 22 / 36, t)!,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 1,
                        style: HorizontType.brand.copyWith(
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                RoundButton(
                  icon: HIcons.settings,
                  semanticLabel: settingsLabel,
                  look: ButtonLook.bright,
                  onTap: onSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(StartHeaderDelegate old) =>
      old.top != top ||
      old.greeting != greeting ||
      old.title != title ||
      old.settingsLabel != settingsLabel;
}

/// The logo as the start page opens: a scalloped shape that rounds into the
/// circle while the sun comes up over the horizon. Without animations it is
/// simply there.
class RisingLogo extends StatefulWidget {
  const RisingLogo({super.key, required this.size});

  final double size;

  @override
  State<RisingLogo> createState() => _RisingLogoState();
}

class _RisingLogoState extends State<RisingLogo>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController.unbounded(vsync: this);
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (HorizontMotion.reduced(context)) {
      _c.value = 1;
    } else {
      unawaited(_c.springTo(1, motion: HorizontMotion.playful));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static final _from = MaterialShapeBorder(shape: MaterialShapes.cookie9Sided);
  static final _to = MaterialShapeBorder(shape: MaterialShapes.circle);

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final v = _c.value;
        return HorizontLogo(
          size: widget.size,
          shape: ShapeBorder.lerp(_from, _to, v.clamp(0.0, 1.0))!,
          // The sun starts a little later and may overshoot with the spring.
          rise: ((v - 0.25) / 0.75).clamp(0.0, 1.1),
        );
      },
    ),
  );
}
