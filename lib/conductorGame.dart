import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class ConductorGame extends StatefulWidget {
  final int timer;

  const ConductorGame({super.key, required this.timer});

  @override
  State<ConductorGame> createState() => _ConductorGameState();
}

class _ConductorGameState extends State<ConductorGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<EnergySegment> _segments = [];
  int _timeLeft = 0;

  // The varied styles and "energy" levels
  final List<PromptStyle> _availableStyles = [
    PromptStyle("WHISPER", 0.15, const Color(0xFF64B5F6)),
    PromptStyle("CALM", 0.3, const Color(0xFF81C784)),
    PromptStyle("CONVERSATIONAL", 0.5, const Color(0xFFFFD54F)),
    PromptStyle("EXCITED", 0.75, const Color(0xFFFF8A65)),
    PromptStyle("LOUD & PASSIONATE", 0.95, const Color(0xFFE57373)),
    PromptStyle("STACCATO", 0.6, const Color(0xFFBA68C8)),
    PromptStyle("SLOW MOTION", 0.25, const Color(0xFF90A4AE)),
    PromptStyle("FAST & URGENT", 0.85, const Color(0xFFFFB74D)),
    PromptStyle("AUTHORITATIVE", 0.7, const Color(0xFF4DB6AC)),
  ];

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.timer;
    _generateSegments();

    // The animation controller will smoothly tick from 0 to 1 over 'timer' seconds
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.timer),
    );

    _controller.addListener(() {
      int newTimeLeft =
          widget.timer - (_controller.value * widget.timer).floor();
      if (newTimeLeft != _timeLeft && newTimeLeft >= 0) {
        setState(() {
          _timeLeft = newTimeLeft;
        });
      }
    });

    // Start slightly after load
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _generateSegments() {
    final random = math.Random();
    double currentTime = 0.0;

    // Initial buffer so the user has time to prepare
    _segments.add(
      EnergySegment(
        startTime: 0.0,
        duration: 3.0,
        style: PromptStyle("GET READY...", 0.05, Colors.grey.shade400),
      ),
    );
    currentTime += 3.0;

    // Fill the rest of the time entirely with random styles
    while (currentTime < widget.timer) {
      double duration = 4.0 + random.nextDouble() * 4.0; // 4 to 8 seconds
      // Bound the last segment exactly to the remaining time
      if (currentTime + duration > widget.timer) {
        duration = widget.timer - currentTime;
      }

      PromptStyle style =
          _availableStyles[random.nextInt(_availableStyles.length)];
      // Prevent consecutive duplicates if possible
      if (_segments.isNotEmpty && _segments.last.style.text == style.text) {
        style =
            _availableStyles[(random.nextInt(_availableStyles.length - 1)) %
                _availableStyles.length];
      }

      _segments.add(
        EnergySegment(startTime: currentTime, duration: duration, style: style),
      );

      currentTime += duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double currentElapsed = _controller.value * widget.timer;

    // Determine which segment is actively crossing the playhead
    EnergySegment? activeSegment;
    for (var seg in _segments) {
      if (currentElapsed >= seg.startTime &&
          currentElapsed < seg.startTime + seg.duration) {
        activeSegment = seg;
        break;
      }
    }
    activeSegment ??= _segments.last;

    bool isFinished = _controller.status == AnimationStatus.completed;

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background color
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP NAVIGATION ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 20.0,
              ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
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

            // --- MAIN TEXT PROMPT ---
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "SPEAK NOW:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(
                          0xFF7A7A7A,
                        ), // Lighter text for dark background
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.2),
                                end: Offset.zero,
                              ).animate(animation),
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            );
                          },
                      child: Text(
                        isFinished ? "WELL DONE!" : activeSegment.style.text,
                        key: ValueKey<String>(
                          isFinished ? "done" : activeSegment.style.text,
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          // Use the color of the segment for the text for deeper immersion
                          color: isFinished
                              ? const Color(0xFFE29B42)
                              : activeSegment.style.color.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- SCROLLING TRACK (THE CONDUCTOR) ---
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF252525), // Dark track background
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: const Color(0xFF333333), // Dark border
                      width: 1.5,
                    ),
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ConductorTrackPainter(
                        currentTime: _controller.value * widget.timer,
                        segments: _segments,
                        totalTime: widget.timer.toDouble(),
                      ),
                    );
                  },
                ),
              ),
            ),

            // --- BOTTOM TIMER ---
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
                        color: Color(0xFF999999), // Adjusted for dark theme
                        letterSpacing: 2.0,
                      ),
                    ),
                    if (!isFinished && _controller.value == 0.0)
                      const Padding(
                        padding: EdgeInsets.only(top: 10.0),
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
}

class PromptStyle {
  final String text;
  final double intensity; // Controls the vertical scale of the segment block
  final Color color;

  PromptStyle(this.text, this.intensity, this.color);
}

class EnergySegment {
  final double startTime; // In seconds
  final double duration; // In seconds
  final PromptStyle style;

  EnergySegment({
    required this.startTime,
    required this.duration,
    required this.style,
  });
}

class ConductorTrackPainter extends CustomPainter {
  final double currentTime;
  final List<EnergySegment> segments;
  final double totalTime;

  ConductorTrackPainter({
    required this.currentTime,
    required this.segments,
    required this.totalTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The "Playhead" is set exactly at 30% of the screen width.
    // Anything crossing this line is what the user should be doing.
    double playheadX = size.width * 0.3;

    // How fast the track moves (pixels per second)
    double pixelsPerSecond = 120.0;

    double centerY = size.height / 2;
    double maxAmplitude = size.height * 0.38; // Maximum height from center

    // 1. Draw central horizontal track line
    final trackLinePaint = Paint()
      ..color =
          const Color(0xFF444444) // Adjusted for dark theme
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      trackLinePaint,
    );

    // 2. Draw segments (Blocks moving leftwards)
    for (var seg in segments) {
      double startX =
          playheadX + (seg.startTime - currentTime) * pixelsPerSecond;
      double endX =
          playheadX +
          (seg.startTime + seg.duration - currentTime) * pixelsPerSecond;

      // Skip drawing if block is completely off-screen
      if (endX < 0 || startX > size.width) continue;

      // Amplitude (height) is determined by "intensity" factor
      double amplitude = math.max(12.0, seg.style.intensity * maxAmplitude);

      // Define rectangle for this block
      // Leave slight padding between blocks on X axis
      Rect rect = Rect.fromLTRB(
        startX + 4,
        centerY - amplitude,
        endX - 4,
        centerY + amplitude,
      );

      // Give it rounded corners
      RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16.0));

      // Paint logic
      bool isActive =
          (currentTime >= seg.startTime &&
          currentTime < seg.startTime + seg.duration);

      Paint blockPaint = Paint()
        ..color = isActive
            ? seg
                  .style
                  .color // full vibrance for active
            : seg.style.color.withOpacity(0.4) // dimmed when approaching/passed
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rrect, blockPaint);

      // Draw subtle border around active element
      if (isActive) {
        Paint borderPaint = Paint()
          ..color =
              const Color(0xFFE0E0E0) // Light border for dark theme
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawRRect(rrect, borderPaint);
      }
    }

    // 3. Draw the Playhead (The cursor indicator)
    final playheadLinePaint = Paint()
      ..color =
          const Color(0xFFE0E0E0) // Light playhead for dark theme
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw vertical line across the entire height at playheadX
    canvas.drawLine(
      Offset(playheadX, size.height * 0.1),
      Offset(playheadX, size.height * 0.9),
      playheadLinePaint,
    );

    // Draw glowing dots/accents on the playhead
    final dotPaint = Paint()
      ..color =
          const Color(0xFFE0E0E0) // Light dots for dark theme
      ..style = PaintingStyle.fill;

    // Top dot
    canvas.drawCircle(Offset(playheadX, size.height * 0.1), 5.0, dotPaint);
    // Bottom dot
    canvas.drawCircle(Offset(playheadX, size.height * 0.9), 5.0, dotPaint);
    // Center point
    canvas.drawCircle(Offset(playheadX, centerY), 6.0, dotPaint);
  }

  @override
  bool shouldRepaint(covariant ConductorTrackPainter oldDelegate) {
    // Continuously repaint as time updates
    return oldDelegate.currentTime != currentTime;
  }
}
