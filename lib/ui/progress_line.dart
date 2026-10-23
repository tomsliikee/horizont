import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/motion.dart';
import 'motion/spring.dart';

/// The page-load line along the bottom of the address pill: it runs on an
/// effect spring, and on reaching 100 % turns into one travelling wave
/// before it fades (design system; PLAN 6.2, Page loads).
class ProgressLine extends StatefulWidget {
  const ProgressLine({super.key, required this.progress, this.height = 3});

  /// 0 to 1 while loading; null when idle.
  final double? progress;
  final double height;

  @override
  State<ProgressLine> createState() => _ProgressLineState();
}

class _ProgressLineState extends State<ProgressLine>
    with TickerProviderStateMixin {
  late final _value = AnimationController.unbounded(vsync: this);
  late final _finish = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  var _visible = false;

  @override
  void initState() {
    super.initState();
    _update(null, widget.progress);
  }

  @override
  void didUpdateWidget(ProgressLine old) {
    super.didUpdateWidget(old);
    _update(old.progress, widget.progress);
  }

  void _update(double? before, double? now) {
    if (now != null) {
      if (!_visible || _finish.isAnimating) {
        _finish.reset();
        _value.value = math.min(_value.value, now);
        if (before == null) _value.value = 0;
      }
      _visible = true;
      unawaited(
        _value.springTo(now.clamp(0.05, 1), motion: HorizontMotion.effects),
      );
    } else if (_visible) {
      // Loaded: run to the end, then the wave and the fade.
      unawaited(
        _value.springTo(1, motion: HorizontMotion.effectsFast).then((_) async {
          if (!mounted) return;
          await _finish.forward(from: 0);
          if (mounted) setState(() => _visible = false);
        }),
      );
    }
  }

  @override
  void dispose() {
    _value.dispose();
    _finish.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return SizedBox(height: widget.height);
    final color = Theme.of(context).colorScheme.primary;
    final reduced = HorizontMotion.reduced(context);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_value, _finish]),
        builder: (context, _) => CustomPaint(
          size: Size(double.infinity, widget.height + 4),
          painter: _LinePainter(
            value: _value.value.clamp(0.0, 1.0),
            finish: _finish.value,
            color: color,
            thickness: widget.height,
            wave: !reduced,
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.value,
    required this.finish,
    required this.color,
    required this.thickness,
    required this.wave,
  });

  final double value;
  final double finish;
  final Color color;
  final double thickness;
  final bool wave;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = finish < 0.55 ? 1.0 : 1 - (finish - 0.55) / 0.45;
    final paint = Paint()
      ..color = color.withValues(alpha: color.a * fade.clamp(0.0, 1.0))
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final y = size.height / 2;
    final end = size.width * value;
    if (finish == 0 || !wave) {
      canvas.drawLine(
        Offset(thickness / 2, y),
        Offset(math.max(thickness / 2, end), y),
        paint,
      );
      return;
    }
    // One wave travels along the full line, its height rising and falling.
    final path = Path();
    final crest = size.width * finish;
    final amp = 2.2 * math.sin(finish * math.pi);
    for (var x = 0.0; x <= end; x += 2) {
      final d = (x - crest) / 28;
      final dy = amp * math.exp(-d * d) * math.sin(d * math.pi);
      if (x == 0) {
        path.moveTo(x, y + dy);
      } else {
        path.lineTo(x, y + dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.value != value || old.finish != finish || old.color != color;
}
