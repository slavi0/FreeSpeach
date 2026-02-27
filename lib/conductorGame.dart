import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class ConductorGame extends StatefulWidget {
  final int timer;

  const ConductorGame({super.key, required this.timer});

  @override
  State<ConductorGame> createState() => _ConductorGameState();
}

class _ConductorGameState extends State<ConductorGame> {
  // Game state
  late int _timeLeft;
  Timer? _gameTimer;
  Timer? _wordTimer;

  // Words/Styles management
  String _currentStyle = "GET READY...";
  final Random _random = Random();

  final List<String> _styles = [
    "WHISPER",
    "EXCITED",
    "AUTHORITATIVE",
    "LIKE A NEWSCASTER",
    "SAD",
    "STACCATO",
    "SARCASTIC",
    "FAST",
    "SLOW MOTION",
    "LIKE A ROBOT",
    "SHAKESPEAREAN",
    "AS A QUESTION?",
    "LAUGHING",
    "DRAMATIC PAUSES",
    "PLEADING",
  ];

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.timer;
    // Brief delay before the first word appears to let them read "GET READY"
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _changeStyle();
        _startGame();
      }
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _wordTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    // Timer for the overall game duration
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _endGame();
          }
        });
      }
    });

    // Timer to change the word every 6-8 seconds
    _scheduleNextWord();
  }

  void _scheduleNextWord() {
    // Random duration between 6 and 8 seconds
    int nextDuration = 6 + _random.nextInt(3);

    _wordTimer?.cancel();
    _wordTimer = Timer(Duration(seconds: nextDuration), () {
      if (mounted && _timeLeft > 0) {
        _changeStyle();
        _scheduleNextWord(); // Loop
      }
    });
  }

  void _changeStyle() {
    setState(() {
      // Pick a random style, ensure it's different from the current one
      String newStyle = _currentStyle;
      while (newStyle == _currentStyle || newStyle == "GET READY...") {
        newStyle = _styles[_random.nextInt(_styles.length)];
      }
      _currentStyle = newStyle;
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _wordTimer?.cancel();
    setState(() {
      _currentStyle = "TIME'S UP!";
    });
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    if (minutes > 0) {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return seconds.toString();
  }

  @override
  Widget build(BuildContext context) {
    bool isFinished = _timeLeft <= 0;

    return Scaffold(
      backgroundColor: isFinished
          ? Colors.black87
          : const Color(0xFF1E1E2C), // Deep premium background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
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
                      color: Color(0xFFE29B42),
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.close, size: 28, color: Colors.white54),
                        Text(
                          "(Quit)",
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // The Conductor Prompt
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Text(
                  _currentStyle,
                  key: ValueKey<String>(_currentStyle),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isFinished ? 48 : 56,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    color: isFinished ? Colors.redAccent : Colors.white,
                    shadows: [
                      Shadow(
                        color: isFinished
                            ? Colors.red.withOpacity(0.5)
                            : Colors.blueAccent.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Subtitle
              Text(
                isFinished
                    ? "Well done!"
                    : "Keep speaking, but change your style to match the prompt above!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white54,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const Spacer(flex: 3),

              // Bottom Timer
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _timeLeft <= 10 && !isFinished
                          ? Colors.redAccent
                          : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: _timeLeft <= 10 && !isFinished
                            ? Colors.redAccent
                            : Colors.white70,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _formatTime(_timeLeft),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _timeLeft <= 10 && !isFinished
                              ? Colors.redAccent
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
