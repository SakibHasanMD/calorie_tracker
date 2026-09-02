import 'package:equatable/equatable.dart';

import '../../../food_catalog/domain/entities/food.dart';

/// A logged food entry in the user's diary.
///
/// The food snapshot ([foodName], [measurementType]) is captured at log time so
/// that subsequent edits to the food catalog (e.g. a name change) do not
/// silently rewrite the user's history.
class DiaryEntry extends Equatable {
  const DiaryEntry({
    required this.id,
    required this.foodId,
    required this.foodName,
    required this.measurementType,
    required this.amount,
    required this.calories,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// `null` for not-yet-persisted entries.
  final int? id;

  /// The id of the food this entry refers to (seeded or `custom_<uuid>`).
  final String foodId;

  /// Snapshot of the food's display name at the time the entry was logged.
  final String foodName;

  final MeasurementType measurementType;

  /// Grams if [measurementType] is `gram`, otherwise the number of pieces.
  final double amount;

  /// Computed calories for this entry (amount × per-gram or per-piece rate).
  final double calories;

  /// The calendar day this entry counts toward, as `YYYY-MM-DD` in local time.
  final String entryDate;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convenience: the date this entry counts toward as a `DateTime` (midnight
  /// local on [entryDate]). Used for date-range queries.
  DateTime get entryDateAsDateTime {
    final parts = entryDate.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  DiaryEntry copyWith({
    int? id,
    String? foodId,
    String? foodName,
    MeasurementType? measurementType,
    double? amount,
    double? calories,
    String? entryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      measurementType: measurementType ?? this.measurementType,
      amount: amount ?? this.amount,
      calories: calories ?? this.calories,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        foodId,
        foodName,
        measurementType,
        amount,
        calories,
        entryDate,
        createdAt,
        updatedAt,
      ];
}
