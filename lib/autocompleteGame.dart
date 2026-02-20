import 'package:flutter/material.dart';

class AutocompleteGame extends StatelessWidget {
  final int quantity;
  final int timer;

  // Constructor to receive settings from the settings screen
  const AutocompleteGame({
    super.key,
    required this.quantity,
    required this.timer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: const Text("Autocomplete")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_circle_fill, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            Text(
              "Game Started!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Topics: $quantity | Time: ${timer}s",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("QUIT GAME"),
            ),
          ],
        ),
      ),
    );
  }
}
