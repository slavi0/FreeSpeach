import 'package:flutter/material.dart';
import 'package:free_speach/analogiesGame.dart';
import 'package:free_speach/autocompleteGame.dart';
import 'package:free_speach/conductorGame.dart';
import 'package:free_speach/gameConfig.dart';
import 'package:free_speach/powerConductorGame.dart';
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
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green[400]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.config.name} Settings',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.green[400],
            inactiveTrackColor: Colors.green[900]?.withOpacity(0.3),
            thumbColor: Colors.green[400],
            overlayColor: Colors.green[400]?.withOpacity(0.15),
            valueIndicatorColor: Colors.green[700],
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 40.0),
            children: [
              // Quantity slider
              if (widget.config.showQuantity) ...[
                Text(
                  "${widget.config.quantityLabel}: ${_quantity.round()}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[400],
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[400],
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

              // Rounds slider
              if (widget.config.secondsPerRound) ...[
                Text(
                  "${widget.config.roundsLabel}: ${_rounds.round()}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[400],
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
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => _navigateToGame(context),
                icon: const Icon(Icons.play_arrow),
                label: const Text(
                  "START GAME",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),

              // BACK BUTTON
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[400],
                  side: BorderSide(color: Colors.red[400]!, width: 1.5),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Back to Menu",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
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
      case "Style Conductor":
        gameWidget = ConductorGame(timer: _timer.round());
        break;
      case "Power Conductor":
        gameWidget = PowerConductorGame(timer: _timer.round());
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
