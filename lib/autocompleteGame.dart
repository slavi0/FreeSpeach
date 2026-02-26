import 'package:flutter/material.dart';
import 'games/rapid_fire/rapid_fire_controller.dart';

/// Rapid‑fire autocomplete game
class AutocompleteGame extends StatefulWidget {
  final int quantity; // number of rounds
  final int timer; // seconds per round

  const AutocompleteGame({
    super.key,
    required this.quantity,
    required this.timer,
  });

  @override
  State<AutocompleteGame> createState() => _AutocompleteGameState();
}

class _AutocompleteGameState extends State<AutocompleteGame>
    with SingleTickerProviderStateMixin {
  late RapidFireController _controller;
  late List<String> _prompts;
  String _currentPrompt = '';

  @override
  void initState() {
    super.initState();
    _prompts = _loadPrompts();
    _controller = RapidFireController(
      vsync: this,
      totalRounds: widget.quantity,
      secondsPerRound: widget.timer,
    );

    _controller.roundNotifier.addListener(_onRoundChanged);
    _controller.finishedNotifier.addListener(_onFinished);
    _setPromptForRound(_controller.roundNotifier.value);
    _controller.start();
  }

  void _onRoundChanged() {
    _setPromptForRound(_controller.roundNotifier.value);
  }

  void _setPromptForRound(int round) {
    if (round <= 0) return;
    final idx = (round - 1) % _prompts.length;
    setState(() {
      _currentPrompt = _prompts[idx];
    });
  }

  void _onFinished() {
    setState(() {});
  }

  List<String> _loadPrompts() {
    return [
      "The best way to predict the future is to…",
      "If I were an animal I would be a…",
      "A secret talent I have is…",
      "The one thing I can't live without is…",
      "My ideal vacation would involve…",
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: const Text("Autocomplete")),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.finishedNotifier,
        builder: (context, finished, _) {
          return finished ? _buildFinishedView() : _buildGameView();
        },
      ),
    );
  }

  Widget _buildGameView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPromptBox(),
          const SizedBox(height: 20),
          _buildStatusBox(),
          const SizedBox(height: 20),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildPromptBox() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          _currentPrompt,
          style: const TextStyle(color: Colors.white, fontSize: 22),
          textAlign: TextAlign.center,
        ),
      );

  Widget _buildStatusBox() {
    return Column(
      children: [
        ValueListenableBuilder<int>(
          valueListenable: _controller.roundNotifier,
          builder: (_, round, __) => Text(
            "Round $round / ${widget.quantity}",
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<double>(
          valueListenable: _controller.timeNotifier,
          builder: (_, time, __) => Text(
            "Time: ${time.toStringAsFixed(1)}s",
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: _controller.isPausedNotifier,
          builder: (_, paused, __) {
            return ElevatedButton(
              onPressed: paused ? _controller.resume : _controller.pause,
              child: Text(paused ? "RESUME" : "PAUSE"),
            );
          },
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("QUIT GAME"),
        ),
      ],
    );
  }

  Widget _buildFinishedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.flag, size: 100, color: Colors.green),
          const SizedBox(height: 20),
          const Text(
            "Game Over!",
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Back to Menu"),
          ),
        ],
      ),
    );
  }
}
