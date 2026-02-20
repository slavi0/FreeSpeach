import 'package:flutter/material.dart';
import 'package:free_speach/analogiesGame.dart';
import 'package:free_speach/autocompleteGame.dart';
import 'package:free_speach/conductorGame.dart';
import 'package:free_speach/gameConfig.dart';
import 'package:free_speach/tripleStepGame.dart';

class GameSettingsScreen extends StatefulWidget {
  final GameConfig config;

  const GameSettingsScreen({super.key, required this.config});

  @override
  State<GameSettingsScreen> createState() => _GameSettingsScreenState();
}

class _GameSettingsScreenState extends State<GameSettingsScreen> {
  double _quantity = 5;
  double _timer = 30;
  double _rounds = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.config.name} Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 40.0),
          children: [
            // Quantity slider
            if (widget.config.showQuantity) ...[
              Text(
                "${widget.config.quantityLabel}: ${_quantity.round()}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Slider(
                value: _quantity,
                min: 1,
                max: 20,
                divisions: 19,
                label: _quantity.round().toString(),
                onChanged: (val) => setState(() => _quantity = val),
              ),
              const SizedBox(height: 30),
            ],

            // Timer slider
            if (widget.config.showTimer) ...[
              Text(
                "${widget.config.timerLabel}: ${_timer.round()} seconds",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Slider(
                value: _timer,
                min: 5,
                max: 120,
                divisions: 115,
                label: "${_timer.round()}s",
                onChanged: (val) => setState(() => _timer = val),
              ),
              const SizedBox(height: 30),
            ],

            // Seconds per round slider
            if (widget.config.secondsPerRound) ...[
              Text(
                "${widget.config.roundsLabel}: ${_rounds.round()}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Slider(
                value: _rounds,
                min: 1,
                max: 20,
                divisions: 19,
                label: _rounds.round().toString(),
                onChanged: (val) => setState(() => _rounds = val),
              ),
              const SizedBox(height: 30),
            ],

            const SizedBox(height: 40),

            // START BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
              ),
              onPressed: () => _navigateToGame(context),
              child: const Text(
                "START GAME",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 16),

            // BACK BUTTON
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Back to Menu", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGame(BuildContext context) {
    Widget gameWidget;

    switch (widget.config.name) {
      case "Triple step":
        gameWidget = TripleStepGame(
          quantity: _quantity.round(),
          timer: _timer.round(),
        );
        break;
      case "Conductor":
        gameWidget = ConductorGame(timer: _timer.round());
        break;
      case "Rapid fire autocomplete":
        gameWidget = AutocompleteGame(
          timer: _timer.round(),
          quantity: _rounds.round(),
        );
        break;
      case "Rapid fire analogies":
        gameWidget = AnalogiesGame(
          quantity: _quantity.round(),
          timer: _rounds.round(),
        );
        break;
      default:
        gameWidget = const Placeholder();
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => gameWidget),
    );
  }
}
