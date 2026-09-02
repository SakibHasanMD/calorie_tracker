import 'package:equatable/equatable.dart';

/// How a [Food]'s calories are measured — per gram or per piece.
enum MeasurementType {
  gram,
  piece;

  static MeasurementType fromString(String value) {
    switch (value) {
      case 'gram':
        return MeasurementType.gram;
      case 'piece':
        return MeasurementType.piece;
      default:
        throw ArgumentError.value(value, 'value', 'Unknown measurement type');
    }
  }

  String get wire => name;

  /// Human label used around the UI, e.g. "g" for gram.
  String get unitLabel => this == MeasurementType.gram ? 'g' : 'pcs';
}

/// A food in the catalog — seeded entries plus user-added custom foods.
class Food extends Equatable {
  const Food({
    required this.id,
    required this.name,
    required this.category,
    required this.measurementType,
    required this.caloriesPerGram,
    required this.caloriesPerPiece,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String category;
  final MeasurementType measurementType;

  /// Calories per gram (used when [measurementType] is `gram`); null otherwise.
  final double? caloriesPerGram;

  /// Calories per piece (used when [measurementType] is `piece`); null otherwise.
  final double? caloriesPerPiece;

  /// Whether the user added this food (vs. a bundled seed entry).
  final bool isCustom;

  /// Calorie value that directly applies to [measurementType].
  double get applicableCalories =>
      measurementType == MeasurementType.gram
          ? (caloriesPerGram ?? 0)
          : (caloriesPerPiece ?? 0);

  Food copyWith({
    String? id,
    String? name,
    String? category,
    MeasurementType? measurementType,
    double? caloriesPerGram,
    bool clearCaloriesPerGram = false,
    double? caloriesPerPiece,
    bool clearCaloriesPerPiece = false,
    bool? isCustom,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      measurementType: measurementType ?? this.measurementType,
      caloriesPerGram:
          clearCaloriesPerGram ? null : (caloriesPerGram ?? this.caloriesPerGram),
      caloriesPerPiece: clearCaloriesPerPiece
          ? null
          : (caloriesPerPiece ?? this.caloriesPerPiece),
      isCustom: isCustom ?? this.isCustom,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        measurementType,
        caloriesPerGram,
        caloriesPerPiece,
        isCustom,
      ];
}