import '../../../../core/error/exceptions.dart';
import '../../domain/entities/diary_entry.dart';
import '../../../food_catalog/domain/entities/food.dart';

/// sqflite row mapping for [DiaryEntry].
class DiaryEntryModel extends DiaryEntry {
  const DiaryEntryModel({
    required super.id,
    required super.foodId,
    required super.foodName,
    required super.measurementType,
    required super.amount,
    required super.calories,
    required super.entryDate,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Build from a sqflite row. [MeasurementType.fromString] throws on bad
  /// data — that surfaces as a [CacheException] from the datasource.
  factory DiaryEntryModel.fromMap(Map<String, Object?> map) {
    try {
      return DiaryEntryModel(
        id: map['id'] as int?,
        foodId: map['foodId'] as String,
        foodName: map['foodName'] as String,
        measurementType:
            MeasurementType.fromString(map['measurementType'] as String),
        amount: (map['amount'] as num).toDouble(),
        calories: (map['calories'] as num).toDouble(),
        entryDate: map['entryDate'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
    } catch (e) {
      throw CacheException('Failed to parse diary row: $e');
    }
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'measurementType': measurementType.wire,
      'amount': amount,
      'calories': calories,
      'entryDate': entryDate,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Materialize from a domain [DiaryEntry] for writes. `id` is taken
  /// straight through.
  factory DiaryEntryModel.fromEntity(DiaryEntry e) => DiaryEntryModel(
        id: e.id,
        foodId: e.foodId,
        foodName: e.foodName,
        measurementType: e.measurementType,
        amount: e.amount,
        calories: e.calories,
        entryDate: e.entryDate,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );
}
