import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/diary_entry.dart';
import '../../domain/usecases/get_entries_for_date.dart';
import 'daily_diary_state.dart';

/// Loads and holds the entries + total for a single calendar day.
///
/// Used by Home, Day Detail, and any other screen that needs "today's diary"
/// or "this day's diary." Calling [load] again with the same date is a no-op
/// state-wise (just refreshes from the source of truth).
class DailyDiaryCubit extends Cubit<DailyDiaryState> {
  DailyDiaryCubit({required GetEntriesForDate getEntriesForDate})
      : _getEntriesForDate = getEntriesForDate,
        super(const DailyDiaryState());

  final GetEntriesForDate _getEntriesForDate;

  Future<void> load(String date) async {
    emit(state.copyWith(status: DailyDiaryStatus.loading, date: date));
    final result = await _getEntriesForDate(date);
    result.fold(
      (failure) => emit(state.copyWith(
        status: DailyDiaryStatus.error,
        failure: failure,
      )),
      (entries) {
        final total = entries.fold<double>(0, (sum, e) => sum + e.calories);
        emit(state.copyWith(
          status: DailyDiaryStatus.loaded,
          entries: entries,
          totalCalories: total,
        ));
      },
    );
  }

  /// Replace the entries list (e.g. after a local mutation from a form
  /// cubit) and recompute the total. Keeps the same date.
  void setEntries(List<DiaryEntry> entries) {
    final total = entries.fold<double>(0, (sum, e) => sum + e.calories);
    emit(state.copyWith(
      status: DailyDiaryStatus.loaded,
      entries: entries,
      totalCalories: total,
    ));
  }
}
