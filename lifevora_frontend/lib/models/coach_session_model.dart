class CoachMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  CoachMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

class FoodScanResult {
  final String foodName;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final String? imageUrl;

  FoodScanResult({
    required this.foodName,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.imageUrl,
  });
}