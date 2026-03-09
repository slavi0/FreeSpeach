import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

/// Power Conductor — same animated timeline as Style Conductor, but instead
/// of speaking-style names, prompts are numbers 1–10 representing energy level.
/// 1 = barely a whisper, 10 = maximum passion and volume.
class PowerConductorGame extends StatefulWidget {
  final int timer;

  const PowerConductorGame({super.key, required this.timer});

  @override
  State<PowerConductorGame> createState() => _PowerConductorGameState();
}

class _PowerConductorGameState extends State<PowerConductorGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<EnergySegment> _segments = [];
  int _timeLeft = 0;

  /// Energy levels 1‒10 with matching colors and intensity
  static List<EnergyLevel> get _allLevels => [
    EnergyLevel(
      number: 1,
      intensity: 0.08,
      color: const Color(0xFF64B5F6),
    ), // icy blue
    EnergyLevel(
      number: 2,
      intensity: 0.15,
      color: const Color(0xFF81C784),
    ), // soft green
    EnergyLevel(number: 3, intensity: 0.22, color: const Color(0xFFA5D6A7)),
    EnergyLevel(
      number: 4,
      intensity: 0.32,
      color: const Color(0xFFFFD54F),
    ), // warm yellow
    EnergyLevel(number: 5, intensity: 0.45, color: const Color(0xFFFFCA28)),
    EnergyLevel(
      number: 6,
      intensity: 0.55,
      color: const Color(0xFFFFA726),
    ), // orange-ish
    EnergyLevel(number: 7, intensity: 0.65, color: const Color(0xFFFF8A65)),
    EnergyLevel(
      number: 8,
      intensity: 0.75,
      color: const Color(0xFFEF5350),
    ), // red-hot
    EnergyLevel(number: 9, intensity: 0.87, color: const Color(0xFFE53935)),
    EnergyLevel(
      number: 10,
      intensity: 1.00,
      color: const Color(0xFFB71C1C),
    ), // blazing red
  ];

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.timer;
    _generateSegments();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timer),
    );

    _controller.addListener(() {
      final newTimeLeft =
          widget.timer - (_controller.value * widget.timer).floor();
      if (newTimeLeft != _timeLeft && newTimeLeft >= 0) {
        setState(() => _timeLeft = newTimeLeft);
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _controller.forward();
    });
  }

  void _generateSegments() {
    final random = math.Random();
    double currentTime = 0;

    // Short ready buffer
    _segments.add(
      EnergySegment(
        startTime: 0,
        duration: 3,
        level: EnergyLevel(
          number: 0,
          intensity: 0.04,
          color: Colors.grey.shade500,
        ),
        isReady: true,
      ),
    );
    currentTime += 3;

    EnergyLevel? lastLevel;
    while (currentTime < widget.timer) {
      double duration = 4 + random.nextDouble() * 4; // 4–8 s
      if (currentTime + duration > widget.timer) {
        duration = widget.timer - currentTime;
      }

      EnergyLevel level = _allLevels[random.nextInt(_allLevels.length)];
      // Avoid consecutive same number
      if (lastLevel != null && level.number == lastLevel.number) {
        level =
            _allLevels[(random.nextInt(_allLevels.length - 1) + 1) %
                _allLevels.length];
      }

      _segments.add(
        EnergySegment(startTime: currentTime, duration: duration, level: level),
      );

      lastLevel = level;
      currentTime += duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final currentElapsed = _controller.value * widget.timer;

    EnergySegment? active;
    for (final seg in _segments) {
      if (currentElapsed >= seg.startTime &&
          currentElapsed < seg.startTime + seg.duration) {
        active = seg;
        break;
      }
    }
    active ??= _segments.last;

    final isFinished = _controller.status == AnimationStatus.completed;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top navigation ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFE29B42),
                      size: 36,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 24, color: Color(0xFF999999)),
                        Text(
                          "(Esc)",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Main prompt ──────────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "ENERGY LEVEL",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7A7A7A),
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) => SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.2),
                          end: Offset.zero,
                        ).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: isFinished
                          ? Text(
                              "WELL DONE!",
                              key: const ValueKey("done"),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFE29B42),
                                letterSpacing: 2,
                              ),
                            )
                          : active.isReady
                          ? Text(
                              "GET READY...",
                              key: const ValueKey("ready"),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade400,
                                letterSpacing: 1.5,
                              ),
                            )
                          : Column(
                              key: ValueKey(active.level.number),
                              children: [
                                // Big number
                                Text(
                                  "${active.level.number}",
                                  style: TextStyle(
                                    fontSize: 96,
                                    fontWeight: FontWeight.w900,
                                    color: active.level.color,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Energy label
                                Text(
                                  _energyLabel(active.level.number),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: active.level.color.withOpacity(0.75),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Scrolling track ──────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF252525),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: Color(0xFF333333),
                      width: 1.5,
                    ),
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) => CustomPaint(
                    painter: PowerTrackPainter(
                      currentTime: _controller.value * widget.timer,
                      segments: _segments,
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom timer ─────────────────────────────────────────────────
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_timeLeft),
                      style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF999999),
                        letterSpacing: 2,
                      ),
                    ),
                    if (!isFinished && _controller.value == 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          "Get ready...",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF777777),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Short description that accompanies the number on screen
  String _energyLabel(int n) {
    if (n <= 0) return '';
    if (n == 1) return 'BARELY A WHISPER';
    if (n == 2) return 'VERY QUIET';
    if (n == 3) return 'SOFT';
    if (n == 4) return 'CALM';
    if (n == 5) return 'CONVERSATIONAL';
    if (n == 6) return 'EXPRESSIVE';
    if (n == 7) return 'ENERGETIC';
    if (n == 8) return 'INTENSE';
    if (n == 9) return 'POWERFUL';
    return 'MAXIMUM ENERGY!';
  }
}

// ── Data models ──────────────────────────────────────────────────────────────

class EnergyLevel {
  final int number;
  final double intensity;
  final Color color;
  EnergyLevel({
    required this.number,
    required this.intensity,
    required this.color,
  });
}

class EnergySegment {
  final double startTime;
  final double duration;
  final EnergyLevel level;
  final bool isReady;

  EnergySegment({
    required this.startTime,
    required this.duration,
    required this.level,
    this.isReady = false,
  });
}

// ── Track painter ─────────────────────────────────────────────────────────────

class PowerTrackPainter extends CustomPainter {
  final double currentTime;
  final List<EnergySegment> segments;

  PowerTrackPainter({required this.currentTime, required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    const double playheadX_ratio = 0.3;
    final double playheadX = size.width * playheadX_ratio;
    const double pxPerSecond = 120.0;
    final double centerY = size.height / 2;
    final double maxAmplitude = size.height * 0.38;

    // Central track line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      Paint()
        ..color = const Color(0xFF444444)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    for (final seg in segments) {
      final startX = playheadX + (seg.startTime - currentTime) * pxPerSecond;
      final endX =
          playheadX +
          (seg.startTime + seg.duration - currentTime) * pxPerSecond;

      if (endX < 0 || startX > size.width) continue;

      final amplitude = math.max(10.0, seg.level.intensity * maxAmplitude);
      final rect = Rect.fromLTRB(
        startX + 4,
        centerY - amplitude,
        endX - 4,
        centerY + amplitude,
      );
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(14));

      final isActive =
          currentTime >= seg.startTime &&
          currentTime < seg.startTime + seg.duration;

      canvas.drawRRect(
        rrect,
        Paint()
          ..color = isActive
              ? seg.level.color
              : seg.level.color.withOpacity(0.35)
          ..style = PaintingStyle.fill,
      );

      // Draw the number inside the block (only when wide enough)
      if (!seg.isReady && endX - startX > 30) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${seg.level.number}',
            style: TextStyle(
              fontSize: math.min(amplitude * 1.1, 28.0).clamp(10.0, 28.0),
              fontWeight: FontWeight.w900,
              color: Colors.white.withOpacity(isActive ? 0.95 : 0.5),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset((startX + endX) / 2 - tp.width / 2, centerY - tp.height / 2),
        );
      }

      // Active border
      if (isActive) {
        canvas.drawRRect(
          rrect,
          Paint()
            ..color = const Color(0xFFE0E0E0)
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }
    }

    // Playhead line
    final playheadPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(playheadX, size.height * 0.1),
      Offset(playheadX, size.height * 0.9),
      playheadPaint,
    );

    final dotPaint = Paint()
      ..color = const Color(0xFFE0E0E0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(playheadX, size.height * 0.1), 5, dotPaint);
    canvas.drawCircle(Offset(playheadX, size.height * 0.9), 5, dotPaint);
    canvas.drawCircle(Offset(playheadX, centerY), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant PowerTrackPainter old) =>
      old.currentTime != currentTime;
}
