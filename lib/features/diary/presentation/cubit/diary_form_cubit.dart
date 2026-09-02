import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../food_catalog/domain/entities/food.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/usecases/add_diary_entry.dart';
import '../../domain/usecases/update_diary_entry.dart';
import 'diary_form_state.dart';

/// Drives the diary entry form (add + edit).
///
/// Edit mode: pre-populate from an existing [DiaryEntry], including letting
/// the user change which food it is (per the "full access to edit" decision
/// in the roadmap). Save routes to [AddDiaryEntry] or [UpdateDiaryEntry].
class DiaryFormCubit extends Cubit<DiaryFormState> {
  DiaryFormCubit({
    required AddDiaryEntry addEntry,
    required UpdateDiaryEntry updateEntry,
    DiaryEntry? editing,
  })  : _addEntry = addEntry,
        _updateEntry = updateEntry,
        _perUnitCache = _initialPerUnit(editing),
        super(_initialState(editing));

  final AddDiaryEntry _addEntry;
  final UpdateDiaryEntry _updateEntry;

  /// Per-unit calories of the currently selected food. In edit mode this is
  /// derived from the original entry's `calories / amount` because we only
  /// have the snapshot fields, not the full Food.
  final double _perUnitCache;

  static DiaryFormState _initialState(DiaryEntry? editing) {
    if (editing == null) {
      return DiaryFormState(entryDate: _today());
    }
    return DiaryFormState(
      entryDate: editing.entryDateAsDateTime,
      editingEntryId: editing.id,
      amount: editing.amount,
      calories: editing.calories,
    );
  }

  static double _initialPerUnit(DiaryEntry? editing) {
    if (editing == null || editing.amount <= 0) return 0;
    return editing.calories / editing.amount;
  }

  void selectFood(Food food) {
    emit(state.copyWith(
      food: food,
      calories: state.amount * food.applicableCalories,
      clearError: true,
    ));
    // Per-unit cache is local mutable state outside the public state. We
    // can't reassign a final field, so this method actually mutates a
    // separate holder instead. To keep the implementation simple, the cache
    // is derived from the currently-selected food when one is set, and from
    // the edit-snapshot otherwise.
  }

  void clearFood() {
    emit(state.copyWith(
      clearFood: true,
      calories: 0,
      clearError: true,
    ));
  }

  void changeAmount(double amount) {
    if (amount < 0) amount = 0;
    final perUnit = _effectivePerUnit();
    emit(state.copyWith(
      amount: amount,
      calories: amount * perUnit,
      clearError: true,
    ));
  }

  void changeDate(DateTime date) {
    emit(state.copyWith(entryDate: date));
  }

  double _effectivePerUnit() {
    final food = state.food;
    if (food != null) return food.applicableCalories;
    return _perUnitCache;
  }

  Future<void> submit() async {
    final food = state.food;
    final entryDate = state.entryDate;
    if (food == null || state.amount <= 0 || entryDate == null) {
      emit(state.copyWith(
        status: DiaryFormStatus.error,
        errorMessage: 'Pick a food and enter an amount.',
      ));
      return;
    }
    emit(state.copyWith(status: DiaryFormStatus.submitting, clearError: true));
    final now = DateTime.now();
    final dateString = _formatDate(entryDate);

    final editingId = state.editingEntryId;
    if (editingId == null) {
      final draft = DiaryEntry(
        id: null,
        foodId: food.id,
        foodName: food.name,
        measurementType: food.measurementType,
        amount: state.amount,
        calories: state.calories,
        entryDate: dateString,
        createdAt: now,
        updatedAt: now,
      );
      final result = await _addEntry(draft);
      _handleResult(result);
    } else {
      final draft = DiaryEntry(
        id: editingId,
        foodId: food.id,
        foodName: food.name,
        measurementType: food.measurementType,
        amount: state.amount,
        calories: state.calories,
        entryDate: dateString,
        createdAt: now,
        updatedAt: now,
      );
      final result = await _updateEntry(draft);
      _handleResult(result);
    }
  }

  void _handleResult(Either<Failure, DiaryEntry> result) {
    result.fold(
      (failure) => emit(state.copyWith(
        status: DiaryFormStatus.error,
        failure: failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(status: DiaryFormStatus.saved)),
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _formatDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}
