import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/animation.dart';

/// A lightweight timer/round manager used by the two rapid‑fire games.
///
/// Instances are created from a [State] object (to obtain a [TickerProvider])
/// and the two numeric settings that come from the settings screen.  The
/// controller exposes several [ValueNotifier]s that the UI can observe so that
/// only the minimum of widgets rebuild on every frame.
///
/// The public API is intentionally small: `start`, `pause`, `resume` and
/// `dispose`.  When the final round completes the [finishedNotifier]
/// flips to `true` and the widgets are expected to respond (show a "Game over"
/// screen, pop the route, etc.).
///
/// Debug logging (frames longer than 16 ms, per‑round drift) is printed only
/// in debug mode; release builds pay no cost.
class RapidFireController {
  RapidFireController({
    required this.vsync,
    required this.totalRounds,
    required this.secondsPerRound,
  }) {
    assert(totalRounds >= 0 && secondsPerRound >= 0,
        'rounds/seconds must be non‑negative');

    _anim = AnimationController(
      vsync: vsync,
      duration: Duration(seconds: secondsPerRound),
    )
      ..addListener(_tick)
      ..addStatusListener(_status);

    // initialise notifiers so listeners can read them right away
    roundNotifier.value = 0;
    timeNotifier.value = secondsPerRound.toDouble();
    isPausedNotifier.value = false;
    finishedNotifier.value = false;
  }

  /// How many rounds the game should run for.  (Also exposed in the UI.)
  final int totalRounds;

  /// Length of each round in seconds.
  final int secondsPerRound;

  /// The [TickerProvider] owned by the widget that created this controller.
  final TickerProvider vsync;

  late final AnimationController _anim;

  /// Current round number, 1‑based.  Reaches [totalRounds] just before the
  /// game ends; the value is 0 before `start` is called.
  final ValueNotifier<int> roundNotifier = ValueNotifier<int>(0);

  /// Remaining time in the current round.  Updated every frame.
  final ValueNotifier<double> timeNotifier = ValueNotifier<double>(0);

  /// Whether the controller is currently paused.
  final ValueNotifier<bool> isPausedNotifier = ValueNotifier<bool>(false);

  /// Becomes `true` when the last round finishes.  The UI can listen to this
  /// and switch to a "finished" state.
  final ValueNotifier<bool> finishedNotifier = ValueNotifier<bool>(false);

  // --- debugging helpers -------------------------------------------------
  DateTime? _roundStartTime;
  DateTime? _lastTickTime;
  double _accumulatedDrift = 0;
  int _driftSamples = 0;

  void start() {
    if (totalRounds <= 0 || secondsPerRound <= 0) {
      // nothing to do, immediately finish
      finishedNotifier.value = true;
      return;
    }
    roundNotifier.value = 1;
    _startRound();
  }

  void pause() {
    if (_anim.isAnimating) {
      _anim.stop();
      isPausedNotifier.value = true;
    }
  }

  void resume() {
    if (!_anim.isAnimating && isPausedNotifier.value) {
      // bring timing back in sync
      _lastTickTime = DateTime.now();
      _anim.forward();
      isPausedNotifier.value = false;
    }
  }

  void dispose() {
    _anim.dispose();
    roundNotifier.dispose();
    timeNotifier.dispose();
    isPausedNotifier.dispose();
    finishedNotifier.dispose();
  }

  // -----------------------------------------------------------------------
  void _startRound() {
    _roundStartTime = DateTime.now();
    _lastTickTime = _roundStartTime;
    timeNotifier.value = secondsPerRound.toDouble();
    _anim.reset();
    _anim.forward();
    isPausedNotifier.value = false;
  }

  void _tick() {
    final now = DateTime.now();

    // frame timing debug
    if (_lastTickTime != null) {
      final frameMs = now.difference(_lastTickTime!).inMilliseconds;
      if (frameMs > 16) {
        debugPrint('⚠️ slow frame: ${frameMs}ms');
      }
    }
    _lastTickTime = now;

    final remaining = secondsPerRound * (1 - _anim.value);
    timeNotifier.value = remaining.clamp(0, secondsPerRound.toDouble());
  }

  void _status(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // compute drift for this round
      assert(_roundStartTime != null);
      final now = DateTime.now();
      final actualMs = now.difference(_roundStartTime!).inMilliseconds;
      final expectedMs = secondsPerRound * 1000;
      final drift = actualMs - expectedMs;
      _accumulatedDrift += drift;
      _driftSamples += 1;
      debugPrint('round ${roundNotifier.value} drift=${drift}ms');

      if (roundNotifier.value >= totalRounds) {
        if (_driftSamples > 0) {
          final avg = _accumulatedDrift / _driftSamples;
          debugPrint('average round drift ${avg.toStringAsFixed(1)}ms');
        }
        finishedNotifier.value = true;
      } else {
        roundNotifier.value += 1;
        _startRound();
      }
    }
  }
}
