class GameConfig {
  final String name;
  final String image;

  // Visibility flags: Which settings does this game actually use?
  final bool showQuantity; // Topics or Analogies
  final String quantityLabel; // The text to display
  final double minQuantity;
  final double maxQuantity;

  final bool showTimer; // Seconds
  final String timerLabel; // The text to display
  final double minTimer;
  final double maxTimer;

  final bool secondsPerRound; // Number of rounds
  final String roundsLabel; // The text to display
  final double minRounds;
  final double maxRounds;

  GameConfig({
    required this.name,
    required this.image,
    this.showQuantity = false,
    this.quantityLabel = "Quantity",
    this.minQuantity = 1,
    this.maxQuantity = 20,
    this.showTimer = false,
    this.timerLabel = "Timer (s)",
    this.minTimer = 5,
    this.maxTimer = 120,
    this.secondsPerRound = false,
    this.roundsLabel = "Rounds",
    this.minRounds = 1,
    this.maxRounds = 20,
  });
}
