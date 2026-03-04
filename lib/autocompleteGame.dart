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
    with TickerProviderStateMixin {
  late RapidFireController _controller;
  late List<String> _prompts;
  String _currentPrompt = '';
  late AnimationController _promptAnimation;

  @override
  void initState() {
    super.initState();
    _promptAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _prompts = _loadPrompts();
    _prompts.shuffle();
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
    _promptAnimation.reset();
    _promptAnimation.forward();
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
    _promptAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("Autocomplete"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _controller.finishedNotifier,
        builder: (context, finished, _) {
          return finished ? _buildFinishedView() : _buildGameView();
        },
      ),
    );
  }

  Widget _buildGameView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPromptCard(),
                const SizedBox(height: 48),
                _buildProgressBar(),
                const SizedBox(height: 24),
                _buildHudRow(),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            _currentPrompt,
            key: ValueKey(_currentPrompt),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return ValueListenableBuilder<double>(
      valueListenable: _controller.timeNotifier,
      builder: (_, time, __) {
        final progress = time / widget.timer;
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation(
                  progress > 0.2 ? Colors.green[400] : Colors.red[400],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<double>(
              valueListenable: _controller.timeNotifier,
              builder: (_, t, __) => Text(
                "${t.toStringAsFixed(1)}s",
                style: TextStyle(
                  color: Colors.green[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHudRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: _controller.roundNotifier,
            builder: (_, round, __) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green[900]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Round",
                    style: TextStyle(
                      color: Colors.green[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$round / ${widget.quantity}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ValueListenableBuilder<bool>(
            valueListenable: _controller.isPausedNotifier,
            builder: (_, paused, __) => Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: paused
                    ? Colors.orange[900]?.withOpacity(0.3)
                    : Colors.green[900]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    paused ? "Paused" : "Playing",
                    style: TextStyle(
                      color: paused ? Colors.orange[400] : Colors.green[400],
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    paused ? Icons.pause_circle : Icons.play_circle,
                    color: paused ? Colors.orange[400] : Colors.green[400],
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: _controller.isPausedNotifier,
              builder: (_, paused, __) => ElevatedButton.icon(
                onPressed: paused ? _controller.resume : _controller.pause,
                icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                label: Text(paused ? "Resume" : "Pause"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: paused
                      ? Colors.green[600]
                      : Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.exit_to_app),
              label: const Text("Quit"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[400],
                side: BorderSide(color: Colors.red[400]!, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            "You completed all ${widget.quantity} rounds",
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green[600],
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Back to Menu",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.flag, size: 100, color: Colors.green),
//           const SizedBox(height: 20),
//           const Text(
//             "Game Over!",
//             style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Back to Menu"),
//           ),
//         ],
//       ),
//     );
//   }
// }
