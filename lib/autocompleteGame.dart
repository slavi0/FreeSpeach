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
      "If I could have any superpower it would be…",
      "The advice I would give my younger self is…",
      "When I'm stressed, I usually…",
      "The most rewarding experience I've had is…",
      "People often tell me that I'm…",
      "If I could change one thing about the world it would be…",
      "The skill I'm most proud of is…",
      "My biggest fear is…",
      "When I accomplish a goal, I feel…",
      "The person who has influenced me the most is…",
      "If I had unlimited time, I would…",
      "The most important thing to me is…",
      "When faced with a difficult decision, I…",
      "My biggest strength is my ability to…",
      "The thing that makes me laugh the most is…",
      "If I could travel anywhere in the world, I would go to…",
      "The book/movie/song that changed my perspective was…",
      "When I'm not working, I enjoy…",
      "The habit I want to develop is…",
      "A moment I'm truly proud of was when…",
      "If I could have dinner with anyone, I would choose…",
      "What drives me forward is…",
      "The skill I wish I had is…",
      "When things don't go as planned, I…",
      "Something that fascinates me is…",
      "If I could master any language it would be…",
      "The type of person I want to become is…",
      "When I see injustice, I feel…",
      "The hobby that brings me the most joy is…",
      "If I could improve one aspect of my life it would be…",
      "The greatest lesson I've learned is…",
      "When I help someone else, I feel…",
      "The dream I've had since childhood is…",
      "People see me as someone who is…",
      "The value I hold most important is…",
      "If I could start a business, it would be…",
      "The moment I realized I had grown was when…",
      "When I'm with people I care about, I…",
      "The challenge I'm currently working through is…",
      "If I could go back in time, I would tell myself to…",
      "The accomplishment I'm most proud of is…",
      "When I think about my future, I feel…",
      "The person I aspire to be like is…",
      "If I could have one guaranteed success, it would be…",
      "The legacy I want to leave behind is…",
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
