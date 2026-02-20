class GameConfig {
  final String name;
  final String image;

  // Visibility flags: Which settings does this game actually use?
  final bool showQuantity; // Topics or Analogies
  final String quantityLabel; // The text to display
  final bool showTimer; // Seconds
  final String timerLabel; // The text to display
  final bool secondsPerRound; // Number of rounds
  final String roundsLabel; // The text to display

  GameConfig({
    required this.name,
    required this.image,
    this.showQuantity = false,
    this.quantityLabel = "Quantity",
    this.showTimer = false,
    this.timerLabel = "Timer (s)",
    this.secondsPerRound = false,
    this.roundsLabel = "Rounds",
  });
}
