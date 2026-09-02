import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/calendar_summary.dart';
import '../../domain/usecases/get_calendar_summary.dart';
import 'history_state.dart';

/// Drives the History screen: which period + reference date the user is
/// viewing, and the resulting bucketed [CalendarSummary].
class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit({
    required GetCalendarSummary getCalendarSummary,
    DateTime? initialDate,
  })  : _getCalendarSummary = getCalendarSummary,
        super(HistoryState(
          period: CalendarPeriod.month,
          referenceDate: _dateOnly(initialDate ?? DateTime.now()),
        ));

  final GetCalendarSummary _getCalendarSummary;

  /// (Re)loads the summary for the current period/reference date.
  Future<void> load() async {
    emit(state.copyWith(
      status: HistoryStatus.loading,
      clearSummary: true,
      clearFailure: true,
    ));
    await _fetch();
  }

  Future<void> changePeriod(CalendarPeriod period) async {
    emit(state.copyWith(
      status: HistoryStatus.loading,
      period: period,
      clearSummary: true,
      clearFailure: true,
    ));
    await _fetch();
  }

  Future<void> goToPrevious() async {
    emit(
      state.copyWith(
        status: HistoryStatus.loading,
        referenceDate: _shift(state.referenceDate!, state.period, -1),
        clearSummary: true,
        clearFailure: true,
      ),
    );
    await _fetch();
  }

  Future<void> goToNext() async {
    emit(
      state.copyWith(
        status: HistoryStatus.loading,
        referenceDate: _shift(state.referenceDate!, state.period, 1),
        clearSummary: true,
        clearFailure: true,
      ),
    );
    await _fetch();
  }

  Future<void> jumpToDate(DateTime date) async {
    emit(state.copyWith(
      status: HistoryStatus.loading,
      referenceDate: _dateOnly(date),
      clearSummary: true,
      clearFailure: true,
    ));
    await _fetch();
  }

  Future<void> _fetch() async {
    final ref = state.referenceDate!;
    final period = state.period;
    final result = await _getCalendarSummary(period, ref);
    result.fold(
      (failure) => emit(state.copyWith(status: HistoryStatus.error, failure: failure)),
      (summary) => emit(state.copyWith(
        status: HistoryStatus.loaded,
        referenceDate: summary.referenceDate,
        summary: summary,
      )),
    );
  }

  /// Shifts [date] by one [period] step in the direction [direction] (±1).
  static DateTime _shift(DateTime date, CalendarPeriod period, int direction) {
    switch (period) {
      case CalendarPeriod.day:
        return _dateOnly(date).add(Duration(days: direction));
      case CalendarPeriod.week:
        return _dateOnly(date).add(Duration(days: 7 * direction));
      case CalendarPeriod.month:
        return DateTime(date.year, date.month + direction, date.day);
      case CalendarPeriod.year:
        return DateTime(date.year + direction, date.month, date.day);
    }
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
