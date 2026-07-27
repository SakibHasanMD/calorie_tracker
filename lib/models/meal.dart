class Meal {
  final int? id;
  final int foodId;
  final String foodName;
  final double? weight; // in grams, if measurementType was 'gram'
  final int? pieces; // count, if measurementType was 'piece'
  final double calories;
  final DateTime createdAt;

  Meal({
    this.id,
    required this.foodId,
    required this.foodName,
    this.weight,
    this.pieces,
    required this.calories,
    required this.createdAt,
  });

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] as int?,
      foodId: map['foodId'] as int,
      foodName: map['foodName'] as String,
      weight: map['weight'] as double?,
      pieces: map['pieces'] as int?,
      calories: map['calories'] as double,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'weight': weight,
      'pieces': pieces,
      'calories': calories,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get amountLabel {
    if (weight != null) {
      final w = weight!;
      final text = w == w.roundToDouble() ? w.toInt().toString() : w.toString();
      return '${text}g';
    } else if (pieces != null) {
      return '$pieces pcs';
    }
    return '';
  }
}
