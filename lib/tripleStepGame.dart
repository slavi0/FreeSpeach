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
  Timer? _countdownTimer;
  bool _isFinished = false;

  // Topic management
  String _currentTopic = "";
  final math.Random _random = math.Random();

  final List<String> _allTopics = [
    "THE END OF AN ERA",
    "A NEW BEGINNING",
    "THE GOLDEN AGE",
    "TECHNOLOGY TODAY",
    "NATURE'S WONDERS",
    "ANCIENT MYTHS",
  ];

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
  late List<bool> _checkboxes;
  List<String> _revealedWords = [];
  int _revealedWordsCount = 0;

  @override
  void initState() {
    super.initState();
    _checkboxes = List.generate(widget.quantity, (_) => false);
    _resetGame();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _resetGame() {
    _countdownTimer?.cancel();
    for (int i = 0; i < _checkboxes.length; i++) {
      _checkboxes[i] = false;
    }
    _sampleWords.shuffle();
    _revealedWords = [];
    while (_revealedWords.length < widget.quantity) {
      final remaining = widget.quantity - _revealedWords.length;
      _revealedWords.addAll(_sampleWords.take(remaining));
    }
    _revealedWordsCount = 0;

    setState(() {
      _isFinished = false;
      _timeLeft = widget.timer;
      _availableTopics = List.from(_allTopics);
      _nextTopic();
    });

    _startTimer();
  }

  void _startTimer() {
    // Reveal one word every (timer / quantity) seconds, evenly spaced
    final revealInterval = widget.quantity > 0
        ? (widget.timer / widget.quantity).floor()
        : widget.timer;

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
          final secondsPassed = widget.timer - _timeLeft;
          if (revealInterval > 0 && secondsPassed % revealInterval == 0) {
            if (_revealedWordsCount < widget.quantity) {
              _revealedWordsCount++;
            }
          }
        } else {
          t.cancel();
          _isFinished = true;
        }
      });
    });
  }

  void _nextTopic() {
    if (_availableTopics.isEmpty) {
      _availableTopics = List.from(_allTopics);
    }
    final idx = _random.nextInt(_availableTopics.length);
    setState(() {
      _currentTopic = _availableTopics[idx];
      _availableTopics.removeAt(idx);
    });
  }

  String _formatTime(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Finished view ──────────────────────────────────────────────────────────
  Widget _buildFinishedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green[900]?.withOpacity(0.3),
            ),
            child: Icon(Icons.check_circle, size: 80, color: Colors.green[400]),
          ),
          const SizedBox(height: 32),
          const Text(
            "Great Job!",
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "You completed the round",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 48),
          // Play Again
          FilledButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.replay),
            label: const Text(
              "Play Again",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green[600],
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Back to menu
          OutlinedButton(
            onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[400],
              side: BorderSide(color: Colors.red[400]!, width: 1.5),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Back to Menu", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // ── Game view ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        body: SafeArea(child: _buildFinishedView()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top navigation row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.green[400],
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.close, size: 20, color: Color(0xFF999999)),
                        Text(
                          "(Esc)",
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Topic heading — green accent
              Text(
                _currentTopic,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.green[400],
                ),
              ),

              const SizedBox(height: 32),

              // Timer — centered at the top of the content area
              Text(
                _formatTime(_timeLeft),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF999999),
                ),
              ),

              const SizedBox(height: 32),

              // Checkbox + word list — takes remaining space, scrollable
              Expanded(
                child: ListView.builder(
                  itemCount: widget.quantity,
                  itemBuilder: (context, index) {
                    final isRevealed = index < _revealedWordsCount;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isRevealed) {
                                setState(() {
                                  _checkboxes[index] = !_checkboxes[index];
                                });
                              }
                            },
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _checkboxes[index]
                                    ? Colors.green[500]
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _checkboxes[index]
                                      ? Colors.green[400]!
                                      : const Color(0xFF5A5A5A),
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: _checkboxes[index]
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 22,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: AnimatedOpacity(
                              opacity: isRevealed ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 400),
                              child: Text(
                                _revealedWords[index],
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Color(0xFFE0E0E0),
                                ),
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
      ),
    );
  }
}
