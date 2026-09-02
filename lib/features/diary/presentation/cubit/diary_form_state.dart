import 'package:equatable/equatable.dart';

import '../../../food_catalog/domain/entities/food.dart';

/// State for the diary entry form (add / edit).
///
/// Tracks selected food + amount and exposes the live-computed calorie value
/// for the UI. Submission state is separate so the form can show validation
/// errors without losing the user's input.
enum DiaryFormStatus { editing, submitting, saved, error }

class DiaryFormState extends Equatable {
  const DiaryFormState({
    this.status = DiaryFormStatus.editing,
    this.food,
    this.amount = 0,
    this.entryDate,
    this.editingEntryId,
    this.calories = 0,
    this.failure,
    this.errorMessage,
  });

  final DiaryFormStatus status;

  /// The currently selected food. Required for valid submission.
  final Food? food;

  /// Grams or piece count, depending on [food.measurementType].
  final double amount;

  /// The day this entry counts toward. Defaults to today for new entries and
  /// to the original day for edits.
  final DateTime? entryDate;

  /// When non-null, this form is editing the entry with this id.
  final int? editingEntryId;

  /// Live-computed calories = `amount × applicableCalories` of [food].
  final double calories;

  /// Underlying failure when [status] == [DiaryFormStatus.error].
  final Object? failure;

  /// Short message suitable for showing to the user.
  final String? errorMessage;

  bool get canSubmit => food != null && amount > 0;

  DiaryFormState copyWith({
    DiaryFormStatus? status,
    Food? food,
    bool clearFood = false,
    double? amount,
    DateTime? entryDate,
    int? editingEntryId,
    bool clearEditingEntryId = false,
    double? calories,
    Object? failure,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DiaryFormState(
      status: status ?? this.status,
      food: clearFood ? null : (food ?? this.food),
      amount: amount ?? this.amount,
      entryDate: entryDate ?? this.entryDate,
      editingEntryId:
          clearEditingEntryId ? null : (editingEntryId ?? this.editingEntryId),
      calories: calories ?? this.calories,
      failure: clearError ? null : (failure ?? this.failure),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        food,
        amount,
        entryDate,
        editingEntryId,
        calories,
        failure,
        errorMessage,
      ];
}
