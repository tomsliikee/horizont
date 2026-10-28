import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:motor/motor.dart';

import '../browser/browser_providers.dart';
import '../browser/status_bar/page_message.dart';
import '../browser/web_engine.dart';
import '../theme/motion.dart';
import '../ui/haptics.dart';
import '../ui/morph_indicator.dart';

/// Pull to refresh over the page. The page script reports how far a finger
/// pulls the page down from its top; the indicator comes down with it,
/// slower the further it goes, and winds up. Let go past the threshold it
/// stays and morphs while the page loads again.
class PullRefresh extends ConsumerStatefulWidget {
  const PullRefresh({super.key, required this.top});

  /// Where the page starts on screen.
  final double top;

  /// How far, in page pixels, a pull must go to refresh.
  static const threshold = 110.0;

  /// Where the indicator rests while the page loads, below [top].
  static const rest = 72.0;

  @override
  ConsumerState<PullRefresh> createState() => _PullRefreshState();
}

class _PullRefreshState extends ConsumerState<PullRefresh> {
  StreamSubscription<PageMessage>? _sub;
  var _pull = 0.0;
  var _armed = false;
  var _refreshing = false;
  var _sawLoading = false;
  Timer? _giveUp;

  @override
  void initState() {
    super.initState();
    ref.listenManual<WebEngine>(webEngineProvider, (_, engine) {
      _listen(engine);
      _settle();
    }, fireImmediately: true);
    ref.listenManual(pageStateProvider.select((p) => p.loading), (_, loading) {
      if (!_refreshing) return;
      if (loading) {
        _sawLoading = true;
      } else if (_sawLoading) {
        _settle();
      }
    });
  }

  void _listen(WebEngine engine) {
    unawaited(_sub?.cancel());
    _sub = engine.messages.listen((m) {
      if (m is PullMessage) _onPull(m);
    });
  }

  void _onPull(PullMessage m) {
    if (_refreshing) return;
    if (m.end) {
      if (_armed) {
        Haptics.play(Haptic.confirm);
        setState(() {
          _refreshing = true;
          _sawLoading = false;
          _pull = 0;
          _armed = false;
        });
        unawaited(ref.read(webEngineProvider).reload());
        // A page that never reports loading still lets the indicator go.
        _giveUp?.cancel();
        _giveUp = Timer(const Duration(seconds: 12), _settle);
      } else {
        setState(() => _pull = 0);
      }
      return;
    }
    final armed = m.distance >= PullRefresh.threshold;
    if (armed != _armed) {
      Haptics.play(armed ? Haptic.threshold : Haptic.release);
    }
    setState(() {
      _pull = m.distance;
      _armed = armed;
    });
  }

  void _settle() {
    _giveUp?.cancel();
    if (!mounted) return;
    setState(() {
      _refreshing = false;
      _armed = false;
      _pull = 0;
    });
  }

  @override
  void dispose() {
    _giveUp?.cancel();
    unawaited(_sub?.cancel());
    super.dispose();
  }

  /// How far the indicator comes down for a pull: less and less, so it
  /// never runs away from the top.
  static double _travel(double pull) => 150 * (1 - math.exp(-pull / 170));

  @override
  Widget build(BuildContext context) {
    const size = 48.0;
    final down = _refreshing ? PullRefresh.rest : _travel(_pull);
    final progress = (_pull / PullRefresh.threshold).clamp(0.0, 1.0);
    return Positioned(
      top: widget.top - size,
      left: 0,
      right: 0,
      height: size,
      child: IgnorePointer(
        child: SingleMotionBuilder(
          value: down,
          motion: HorizontMotion.spatialFor(
            context,
            HorizontMotion.spatialFast,
          ),
          builder: (context, y, _) {
            if (y < 1) return const SizedBox.shrink();
            return Transform.translate(
              offset: Offset(0, y),
              child: Opacity(
                opacity: (y / 40).clamp(0.0, 1.0),
                child: Center(
                  child: MorphIndicator(
                    progress: _refreshing ? 1 : progress,
                    spinning: _refreshing,
                    size: _armed || _refreshing ? size : size * 0.9,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
