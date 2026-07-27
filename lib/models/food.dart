class Food {
  final int? id;
  final String name;
  final double? caloriePerGram; // used when measurementType == 'gram'
  final double? caloriePerPiece; // used when measurementType == 'piece'
  final String measurementType; // 'gram' or 'piece'

  Food({
    this.id,
    required this.name,
    this.caloriePerGram,
    this.caloriePerPiece,
    required this.measurementType,
  });

  factory Food.fromMap(Map<String, dynamic> map) {
    return Food(
      id: map['id'] as int?,
      name: map['name'] as String,
      caloriePerGram: map['caloriePerGram'] as double?,
      caloriePerPiece: map['caloriePerPiece'] as double?,
      measurementType: map['measurementType'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'caloriePerGram': caloriePerGram,
      'caloriePerPiece': caloriePerPiece,
      'measurementType': measurementType,
    };
  }

  bool get isGramBased => measurementType == 'gram';
}
