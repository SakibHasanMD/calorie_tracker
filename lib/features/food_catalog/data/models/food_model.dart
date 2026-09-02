import '../../domain/entities/food.dart';

/// Serializable [Food] used for JSON round-tripping (seed file, persisted
/// `food_catalog.json`, and `custom_foods.json`).
class FoodModel extends Food {
  const FoodModel({
    required super.id,
    required super.name,
    required super.category,
    required super.measurementType,
    required super.caloriesPerGram,
    required super.caloriesPerPiece,
    super.isCustom,
    this.createdAt,
  });

  /// Populated only for custom foods (`custom_foods.json`).
  final String? createdAt;

  factory FoodModel.fromJson(Map<String, dynamic> json) {
    return FoodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String? ?? '',
      measurementType: MeasurementType.fromString(json['measurementType'] as String),
      caloriesPerGram: (json['caloriesPerGram'] as num?)?.toDouble(),
      caloriesPerPiece: (json['caloriesPerPiece'] as num?)?.toDouble(),
      isCustom: json['isCustom'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'measurementType': measurementType.wire,
      'caloriesPerGram': caloriesPerGram,
      'caloriesPerPiece': caloriesPerPiece,
      if (isCustom) 'isCustom': isCustom,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  factory FoodModel.fromEntity(Food food, {String? createdAt}) {
    return FoodModel(
      id: food.id,
      name: food.name,
      category: food.category,
      measurementType: food.measurementType,
      caloriesPerGram: food.caloriesPerGram,
      caloriesPerPiece: food.caloriesPerPiece,
      isCustom: food.isCustom,
      createdAt: createdAt ?? (food is FoodModel ? food.createdAt : null),
    );
  }
}