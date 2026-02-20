import 'package:flutter/material.dart';
import 'package:free_speach/gameSettings.dart';
import 'package:free_speach/gameConfig.dart';

class HomeMenu extends StatelessWidget {
  // A quick list of game data to keep the code clean
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
      name: "Conductor",
      image: "assets/game2.png",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Choose a Game')),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: games.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4,
            margin: EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              // This makes the box clickable!
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Pass the entire GameConfig object from your list
                    builder: (context) =>
                        GameSettingsScreen(config: games[index]),
                  ),
                );
              },
              child: Column(
                children: [
                  // Game Image
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300], // Placeholder color
                      child: Icon(
                        Icons.gamepad,
                        size: 50,
                      ), // Swap with Image.asset
                    ),
                  ),
                  // Game Title
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      games[index].name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
