import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../theme/motion.dart';
import 'page_color.dart';
import 'status_bar_look.dart';

/// The most columns the band is painted in; fewer colours use fewer.
const _maxColumns = 48;

/// The invisible margin below the edge that still counts as a tap on it.
const _tapMargin = 8.0;

/// The band under the status bar, painted by the app because Android 15+
/// draws no colour there (PLAN 5.2). Colour and edge move on effect springs,
/// so the solid band becomes the soft edge without a jump (PLAN 5.5).
///
/// While the edge shows, tapping it calls [onTapEdge]: Android does not
/// deliver taps on the status bar itself (R5, `docs/spikes.md`).
class StatusBarTint extends StatelessWidget {
  const StatusBarTint({
    super.key,
    required this.look,
    required this.height,
    this.edgeHeight = 16,
    this.onTapEdge,
  });

  final StatusBarLook look;

  /// The status bar's height, `MediaQuery.viewPadding.top`.
  final double height;

  /// How far the soft edge reaches below the bar; 0 for none.
  final double edgeHeight;
  final VoidCallback? onTapEdge;

  @override
  Widget build(BuildContext context) {
    final motion = HorizontMotion.effects;
    final tint = _ColorsMotion(
      colors: look.colors,
      motion: motion,
      builder: (context, colors) => SingleMotionBuilder(
        value: look.edge ? 1 : 0,
        motion: motion,
        builder: (context, edge, _) => _Band(
          colors: colors,
          edge: edge.clamp(0.0, 1.0),
          height: height,
          edgeHeight: edgeHeight,
        ),
      ),
    );
    return SizedBox(
      height: height + edgeHeight + _tapMargin,
      child: Stack(
        children: [
          IgnorePointer(child: tint),
          if (look.edge && onTapEdge != null)
            Positioned(
              left: 0,
              right: 0,
              top: height,
              height: edgeHeight + _tapMargin,
              child: Semantics(
                button: true,
                container: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTapEdge,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Moves the band's colours to new ones on [motion]. When the number of
/// colours changes (a single colour becoming a gradient) the old ones are
/// spread to the new count first, so the change still glides.
class _ColorsMotion extends StatefulWidget {
  const _ColorsMotion({
    required this.colors,
    required this.motion,
    required this.builder,
  });

  final List<Color> colors;
  final Motion motion;
  final Widget Function(BuildContext context, List<Color> colors) builder;

  @override
  State<_ColorsMotion> createState() => _ColorsMotionState();
}

class _ColorsMotionState extends State<_ColorsMotion> {
  late List<Color> _from = widget.colors;
  late List<Color> _to = widget.colors;
  late final _progress = _Progress();

  @override
  void didUpdateWidget(_ColorsMotion old) {
    super.didUpdateWidget(old);
    if (listEquals(old.colors, widget.colors)) return;
    // Where the band is right now becomes the start of the next move.
    _from = _blend(_from, _to, _progress.value);
    _to = widget.colors;
    _progress.value = 0;
  }

  @override
  Widget build(BuildContext context) => SingleMotionBuilder(
    key: ValueKey(_to),
    value: 1,
    from: 0,
    motion: widget.motion,
    builder: (context, t, _) {
      _progress.value = t;
      return widget.builder(context, _blend(_from, _to, t));
    },
  );
}

class _Progress {
  double value = 1;
}

/// [a] to [b] at [t], both spread to the longer length.
List<Color> _blend(List<Color> a, List<Color> b, double t) {
  final n = math.max(a.length, b.length);
  Color at(List<Color> l, int i) {
    if (l.length == 1) return l[0];
    final x = i * (l.length - 1) / math.max(1, n - 1);
    final lo = x.floor();
    final hi = math.min(lo + 1, l.length - 1);
    return Color.lerp(l[lo], l[hi], x - lo)!;
  }

  return [for (var i = 0; i < n; i++) Color.lerp(at(a, i), at(b, i), t)!];
}

class _Band extends StatelessWidget {
  const _Band({
    required this.colors,
    required this.edge,
    required this.height,
    required this.edgeHeight,
  });

  final List<Color> colors;

  /// 0 for the solid band, 1 for the full soft edge.
  final double edge;
  final double height;
  final double edgeHeight;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(double.infinity, height + edgeHeight),
    painter: _BandPainter(colors, edge, height),
  );
}

/// Solid down to the status bar's height, then the edge fades out below it.
/// Drawn as narrow columns, each with its own vertical gradient shader, so
/// several colours blend across the width without a layer saved over the web
/// view on every frame.
class _BandPainter extends CustomPainter {
  _BandPainter(this.colors, this.edge, this.height);

  final List<Color> colors;
  final double edge;
  final double height;

  Color _at(double x) {
    if (colors.length == 1) return colors[0];
    final p = x.clamp(0.0, 1.0) * (colors.length - 1);
    final lo = p.floor();
    final hi = math.min(lo + 1, colors.length - 1);
    return Color.lerp(colors[lo], colors[hi], p - lo)!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.height <= 0) return;
    final split = (height / size.height).clamp(0.0, 1.0);
    final columns = colors.length == 1 ? 1 : _maxColumns;
    final w = size.width / columns;
    for (var i = 0; i < columns; i++) {
      final color = _at((i + 0.5) / columns);
      final rect = Rect.fromLTWH(i * w, 0, w + 0.5, size.height);
      final shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color,
          color,
          color.withValues(alpha: color.a * edge),
          color.withValues(alpha: 0),
        ],
        stops: [0, split, split, 1],
      ).createShader(rect);
      canvas.drawRect(rect, Paint()..shader = shader);
    }
  }

  @override
  bool shouldRepaint(_BandPainter old) =>
      !listEquals(old.colors, colors) ||
      old.edge != edge ||
      old.height != height;
}

/// The icon brightness for the status bar over [look].
Brightness statusBarContentBrightness(StatusBarLook look) {
  // The icons sit across the whole width, so the average colour decides.
  var sum = 0.0;
  for (final c in look.colors) {
    sum += prototypeLuminance(c);
  }
  return sum / look.colors.length > 0.55 ? Brightness.light : Brightness.dark;
}
