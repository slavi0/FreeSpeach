import 'package:flutter/material.dart';
import 'package:free_speach/gameSettings.dart';
import 'package:free_speach/gameConfig.dart';

class HomeMenu extends StatelessWidget {
  final List<GameConfig> games = [
    GameConfig(
      name: "Triple step",
      image: "assets/game1.png",
      showQuantity: true,
      quantityLabel: "Number of topics",
      showTimer: true,
      timerLabel: "Timer (seconds)",
    ),
    GameConfig(
      name: "Style Conductor",
      image: "assets/game2.png",
      showTimer: true,
      timerLabel: "Timer",
    ),
    GameConfig(
      name: "Power Conductor",
      image: "assets/game2b.png",
      showTimer: true,
      timerLabel: "Timer",
    ),
    GameConfig(
      name: "Rapid fire autocomplete",
      image: "assets/game3.png",
      showTimer: true,
      timerLabel: "How long per round (s)",
      secondsPerRound: true,
      roundsLabel: "How many rounds",
    ),
    GameConfig(
      name: "Rapid fire analogies",
      image: "assets/game4.png",
      showQuantity: true,
      quantityLabel: "Number of analogies",
      secondsPerRound: true,
      roundsLabel: "How many rounds",
    ),
  ];

  // Icon and description for each game
  final List<IconData> _icons = [
    Icons.filter_3,
    Icons.graphic_eq,
    Icons.bolt,
    Icons.flash_on,
    Icons.compare_arrows,
  ];

  final List<String> _descriptions = [
    "Describe three related topics in sequence against the clock.",
    "Match your speaking style to the animated conductor's prompts.",
    "Speak at the energy level shown — from a whisper to full power.",
    "Complete the sentence as fast as you can, round after round.",
    "Find the hidden link between two analogies under pressure.",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Free Speech',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
        itemCount: games.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Material(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          GameSettingsScreen(config: games[index]),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    children: [
                      // Green icon badge
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.green[900]?.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          _icons[index],
                          color: Colors.green[400],
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title + description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              games[index].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _descriptions[index],
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Chevron
                      Icon(
                        Icons.chevron_right,
                        color: Colors.white.withOpacity(0.3),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
