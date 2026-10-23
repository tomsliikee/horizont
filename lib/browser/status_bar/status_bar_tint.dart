import 'package:flutter/widgets.dart';
import 'package:motor/motor.dart';

import '../../theme/motion.dart';
import 'page_color.dart';
import 'status_bar_look.dart';

/// Height of the soft edge below the status bar.
const statusBarEdgeHeight = 16.0;

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
    this.onTapEdge,
  });

  final StatusBarLook look;

  /// The status bar's height, `MediaQuery.viewPadding.top`.
  final double height;
  final VoidCallback? onTapEdge;

  @override
  Widget build(BuildContext context) {
    final motion = HorizontMotion.effects;
    final tint = MotionBuilder<Color>(
      value: look.color,
      motion: motion,
      converter: MotionConverter.colorRgb,
      builder: (context, color, _) => SingleMotionBuilder(
        value: look.edge ? 1 : 0,
        motion: motion,
        builder: (context, edge, _) =>
            _Band(color: color, edge: edge.clamp(0.0, 1.0), height: height),
      ),
    );
    return SizedBox(
      height: height + statusBarEdgeHeight + _tapMargin,
      child: Stack(
        children: [
          IgnorePointer(child: tint),
          if (look.edge && onTapEdge != null)
            Positioned(
              left: 0,
              right: 0,
              top: height,
              height: statusBarEdgeHeight + _tapMargin,
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

class _Band extends StatelessWidget {
  const _Band({required this.color, required this.edge, required this.height});

  final Color color;

  /// 0 for the solid band, 1 for the full soft edge.
  final double edge;
  final double height;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size(double.infinity, height + statusBarEdgeHeight),
    painter: _BandPainter(color, edge, height),
  );
}

/// One gradient rectangle: solid down to the status bar's height, then the
/// edge fades out below it. Drawn with the gradient as the paint, not as a
/// mask, so no layer is saved over the web view on every frame.
class _BandPainter extends CustomPainter {
  _BandPainter(this.color, this.edge, this.height);

  final Color color;
  final double edge;
  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final split = height / size.height;
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
    ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_BandPainter old) =>
      old.color != color || old.edge != edge || old.height != height;
}

/// The icon brightness for the status bar over [look].
Brightness statusBarContentBrightness(StatusBarLook look) =>
    surfaceBrightness(look.color);
