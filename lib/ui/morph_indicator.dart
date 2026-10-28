import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/motion.dart';

/// The Material 3 Expressive loading indicator: a shape on a container that
/// turns and morphs through a row of shapes. While [spinning] it runs on its
/// own; otherwise [progress] (0 to 1, the pull) turns and grows it, so the
/// finger winds it up. Without animations it only fades.
class MorphIndicator extends StatefulWidget {
  const MorphIndicator({
    super.key,
    required this.progress,
    required this.spinning,
    this.size = 48,
  });

  final double progress;
  final bool spinning;
  final double size;

  @override
  State<MorphIndicator> createState() => _MorphIndicatorState();
}

class _MorphIndicatorState extends State<MorphIndicator>
    with SingleTickerProviderStateMixin {
  /// One unit per shape.
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    upperBound: _shapes.length.toDouble(),
  );

  static final _shapes = [
    MaterialShapes.softBurst,
    MaterialShapes.cookie9Sided,
    MaterialShapes.pentagon,
    MaterialShapes.pill,
    MaterialShapes.sunny,
    MaterialShapes.cookie4Sided,
    MaterialShapes.oval,
  ];
  static final _borders = [
    for (final s in _shapes) MaterialShapeBorder(shape: s),
  ];

  @override
  void didUpdateWidget(MorphIndicator old) {
    super.didUpdateWidget(old);
    if (widget.spinning != old.spinning) _sync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    if (widget.spinning && !HorizontMotion.reduced(context)) {
      if (!_spin.isAnimating) {
        _spin.duration = Duration(milliseconds: 650 * _shapes.length);
        unawaited(_spin.repeat());
      }
    } else {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _spin,
      builder: (context, _) {
        final p = widget.progress.clamp(0.0, 1.0);
        // Pulled: the first shape turns with the finger and eases towards
        // the second; spinning: every shape morphs into the next.
        final pos = widget.spinning ? _spin.value : p * 0.6;
        final i = pos.floor() % _shapes.length;
        final f = Curves.easeInOutCubic.transform(pos - pos.floor());
        final border = ShapeBorder.lerp(
          _borders[i],
          _borders[(i + 1) % _shapes.length],
          f,
        )!;
        final turn = widget.spinning ? pos / _shapes.length * 3 : p * 0.75;
        final inner = widget.size * (widget.spinning ? 0.6 : 0.3 + 0.3 * p);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: ShapeDecoration(
            color: scheme.primaryContainer,
            shape: const CircleBorder(),
            shadows: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Transform.rotate(
            angle: turn * 2 * math.pi,
            child: Container(
              width: inner,
              height: inner,
              decoration: ShapeDecoration(
                color: scheme.onPrimaryContainer,
                shape: border,
              ),
            ),
          ),
        );
      },
    );
  }
}
