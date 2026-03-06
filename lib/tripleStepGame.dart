import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

class TripleStepGame extends StatefulWidget {
  final int quantity;
  final int timer;

  const TripleStepGame({
    super.key,
    required this.quantity,
    required this.timer,
  });

  @override
  State<TripleStepGame> createState() => _TripleStepGameState();
}

class _TripleStepGameState extends State<TripleStepGame> {
  // Game state
  int _timeLeft = 0;
  Timer? _timer;

  // Topic management
  String _currentTopic = "";
  final math.Random _random = math.Random();

  // Sample list of topics
  final List<String> _allTopics = [
    "THE END OF AN ERA",
    "A NEW BEGINNING",
    "THE GOLDEN AGE",
    "TECHNOLOGY TODAY",
    "NATURE'S WONDERS",
    "ANCIENT MYTHS",
  ];

  // Sample words for each topic (in a real app, group these by topic)
  final List<String> _sampleWords = [
    "A Newspaper",
    "Cassette Tape",
    "Rotary Phone",
    "Floppy Disk",
    "VHS Tape",
    "Typewriter",
    "Film Camera",
    "Walkman",
    "Encyclopedia",
  ];

  List<String> _availableTopics = [];

  // Checkboxes & Revealed Words
  late List<bool> _checkboxes;
  List<String> _revealedWords = [];
  int _revealedWordsCount = 0;

  @override
  void initState() {
    super.initState();
    _checkboxes = List.generate(widget.quantity, (index) => false);
    _resetGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetGame() {
    for (int i = 0; i < _checkboxes.length; i++) {
      _checkboxes[i] = false;
    }

    // Shuffle and pick words for this round
    _sampleWords.shuffle();

    // Ensure we have enough words to fill the requested quantity
    _revealedWords = [];
    while (_revealedWords.length < widget.quantity) {
      int remaining = widget.quantity - _revealedWords.length;
      _revealedWords.addAll(_sampleWords.take(remaining));
    }

    _revealedWordsCount = 0;

    setState(() {
      _timeLeft = widget.timer;
      _availableTopics = List.from(_allTopics);
      _nextTopic();
    });

    _startGame();
  }

  void _startGame() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;

          // Reveal a new word every 10 seconds
          int secondsPassed = widget.timer - _timeLeft;
          if (secondsPassed > 0 && secondsPassed % 10 == 0) {
            if (_revealedWordsCount < widget.quantity) {
              _revealedWordsCount++;
            }
          }
        } else {
          _timer?.cancel();
          // Time is up logic
        }
      });
    });
  }

  void _nextTopic() {
    if (_availableTopics.isEmpty) {
      _availableTopics = List.from(_allTopics);
    }

    int index = _random.nextInt(_availableTopics.length);
    setState(() {
      _currentTopic = _availableTopics[index];
      _availableTopics.removeAt(index);
    });
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), // Dark background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Navigation Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(
                        0xFFE29B42,
                      ), // Keep orange for back button or change if needed
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

              const SizedBox(height: 10),

              // Title
              Text(
                _currentTopic,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.white, // White text for title
                ),
              ),

              const SizedBox(height: 50),

              // Main Content Area
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pie Timer and Text Timer
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 280,
                          height: 280,
                          child: CustomPaint(
                            painter: PieTimerPainter(
                              // Using max of 1 to avoid division by zero
                              percentage: widget.timer == 0
                                  ? 0
                                  : _timeLeft / widget.timer,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          _formatTime(_timeLeft),
                          style: const TextStyle(
                            fontSize: 68,
                            fontWeight: FontWeight.w900,
                            color: Color(
                              0xFF999999,
                            ), // Lighter gray for timer text on dark background
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 80), // Spacing between timer and list
                    // Checkbox List
                    SizedBox(
                      width: 280,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.quantity,
                        itemBuilder: (context, index) {
                          // Determine if this item has been revealed yet
                          bool isRevealed = index < _revealedWordsCount;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (isRevealed) {
                                      setState(() {
                                        _checkboxes[index] =
                                            !_checkboxes[index];
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _checkboxes[index]
                                          ? const Color(0xFFE29B42)
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: _checkboxes[index]
                                            ? const Color(0xFFE29B42)
                                            : const Color(
                                                0xFF5A5A5A,
                                              ), // Subtler border for checkboxes
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                    child: _checkboxes[index]
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors
                                                .white, // Keep checkmark white or making it dark might contrast better
                                            size: 28,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Text(
                                    isRevealed ? _revealedWords[index] : "",
                                    style: const TextStyle(
                                      fontSize: 22,
                                      color: Color(
                                        0xFFE0E0E0,
                                      ), // Off-white/light gray for list items
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PieTimerPainter extends CustomPainter {
  final double percentage;

  PieTimerPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);

    final paint = Paint()
      ..color =
          const Color(0xFFE29B42) // Matching the checkbox orange color
      ..style = PaintingStyle.fill;

    // Remaining percentage is drawn starting clockwise from the depleted portion
    // E.g. at 85%, top 15% (12 o'clock to approx 2 o'clock) is missing.
    // We draw from where the missing piece ends, clockwise, until 12 o'clock.
    final emptyPercentage = 1.0 - percentage;
    final startAngle = -math.pi / 2 + (2 * math.pi * emptyPercentage);
    final sweepAngle = 2 * math.pi * percentage;

    // If it's completely full, just draw a circle
    if (percentage >= 1.0) {
      canvas.drawCircle(center, radius, paint);
      return;
    }

    // Draw the pie slice holding the remaining time
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant PieTimerPainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
