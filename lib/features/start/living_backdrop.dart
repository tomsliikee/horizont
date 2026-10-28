import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/motion.dart';

/// Large soft shapes in the theme's colours that drift and turn very slowly
/// behind the start page. It only ticks while the page is on screen (the
/// page leaves the tree when hidden, and [TickerMode] stops it in the
/// background) and stands still when animations are off.
class LivingBackdrop extends ConsumerStatefulWidget {
  const LivingBackdrop({super.key});

  @override
  ConsumerState<LivingBackdrop> createState() => _LivingBackdropState();
}

/// False holds the shapes still at their first place; tests set it so
/// pictures are always the same and nothing keeps ticking.
final backdropMovesProvider = Provider<bool>((ref) => true);

class _LivingBackdropState extends ConsumerState<LivingBackdrop>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final _time = ValueNotifier<double>(0);

  /// Where the drift is when the page opens, so it does not always start
  /// from the same picture.
  late final double _start = ref.read(backdropMovesProvider)
      ? math.Random().nextDouble() * 600
      : 0;

  // The drift is slow enough that 30 pictures a second look the same as 120
  // and cost a quarter.
  void _tick(Duration elapsed) {
    final t = _start + elapsed.inMicroseconds / 1e6;
    if (t - _time.value >= 1 / 30) _time.value = t;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still =
        HorizontMotion.reduced(context) || !ref.read(backdropMovesProvider);
    if (still && _ticker.isActive) _ticker.stop();
    if (!still && !_ticker.isActive) _ticker.start();
    if (still) _time.value = _start;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: CustomPaint(
        painter: _BackdropPainter(
          time: _time,
          colors: [
            scheme.primaryContainer,
            scheme.tertiaryContainer,
            scheme.secondaryContainer,
            scheme.primaryContainer,
          ],
          alpha: scheme.brightness == Brightness.dark ? 0.35 : 0.5,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// One shape: where it sits (fractions of the page), its size relative to
/// the width, and how it moves.
class _Blob {
  const _Blob(this.shape, this.x, this.y, this.size, this.period, this.turn);

  final RoundedPolygon Function() shape;
  final double x;
  final double y;
  final double size;

  /// Seconds for one round of its drift.
  final double period;

  /// Turns per minute, negative turns the other way.
  final double turn;
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter({
    required this.time,
    required this.colors,
    required this.alpha,
  }) : super(repaint: time);

  final ValueListenable<double> time;
  final List<Color> colors;
  final double alpha;

  static final _blobs = [
    _Blob(() => MaterialShapes.cookie9Sided, 0.92, 0.08, 0.75, 53, 0.6),
    _Blob(() => MaterialShapes.flower, 0.02, 0.42, 0.62, 61, -0.45),
    _Blob(() => MaterialShapes.pill, 0.88, 0.7, 0.55, 47, 0.35),
    _Blob(() => MaterialShapes.softBurst, 0.18, 0.98, 0.7, 67, -0.5),
  ];

  static final _paths = <int, Path>{};

  static Path _unit(int i) =>
      _paths[i] ??= MaterialShapeBorder(shape: _blobs[i].shape())
          .getOuterPath(const Rect.fromLTWH(-0.5, -0.5, 1, 1));

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final paint = Paint()..isAntiAlias = true;
    for (var i = 0; i < _blobs.length; i++) {
      final b = _blobs[i];
      final phase = t / b.period * 2 * math.pi;
      final side = size.width * b.size;
      final dx = math.sin(phase) * size.width * 0.06;
      final dy = math.cos(phase * 0.8) * size.height * 0.03;
      canvas
        ..save()
        ..translate(size.width * b.x + dx, size.height * b.y + dy)
        ..rotate(t / 60 * b.turn * 2 * math.pi)
        ..scale(side * (1 + math.sin(phase * 1.3) * 0.04))
        ..drawPath(
          _unit(i),
          paint..color = colors[i % colors.length].withValues(alpha: alpha),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter old) =>
      old.colors != colors || old.alpha != alpha || old.time != time;
}
