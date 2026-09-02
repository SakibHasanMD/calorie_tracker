import 'package:bloc_test/bloc_test.dart';
import 'package:calorie_tracker/features/history/domain/entities/calendar_summary.dart';
import 'package:calorie_tracker/features/history/presentation/cubit/history_cubit.dart';
import 'package:calorie_tracker/features/history/presentation/cubit/history_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockGetCalendarSummary getCalendarSummary;

  setUp(() {
    getCalendarSummary = MockGetCalendarSummary();
  });

  CalendarSummary summaryFor(CalendarPeriod period, DateTime ref) {
    return CalendarSummary(
      period: period,
      referenceDate: DateTime(ref.year, ref.month, ref.day),
      startDate: '2024-09-01',
      endDate: '2024-09-15',
      totalCalories: 100,
      buckets: [CalendarBucket(date: _sep15, calories: 100)],
    );
  }

  void stub(CalendarPeriod period, DateTime ref) {
    when(() => getCalendarSummary(period, ref)).thenAnswer(
      (_) async => Right(summaryFor(period, ref)),
    );
  }

  blocTest<HistoryCubit, HistoryState>(
    'load emits loading then loaded with the summary for the current period',
    build: () {
      stub(CalendarPeriod.month, DateTime(2024, 9, 15));
      return HistoryCubit(
        getCalendarSummary: getCalendarSummary,
        initialDate: DateTime(2024, 9, 15),
      );
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      HistoryState(
        status: HistoryStatus.loading,
        period: CalendarPeriod.month,
        referenceDate: DateTime(2024, 9, 15),
      ),
      HistoryState(
        status: HistoryStatus.loaded,
        period: CalendarPeriod.month,
        referenceDate: DateTime(2024, 9, 15),
        summary: summaryFor(CalendarPeriod.month, DateTime(2024, 9, 15)),
      ),
    ],
  );

  blocTest<HistoryCubit, HistoryState>(
    'changePeriod reloads with the new period',
    build: () {
      stub(CalendarPeriod.month, DateTime(2024, 9, 15));
      stub(CalendarPeriod.week, DateTime(2024, 9, 15));
      return HistoryCubit(
        getCalendarSummary: getCalendarSummary,
        initialDate: DateTime(2024, 9, 15),
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.changePeriod(CalendarPeriod.week);
    },
    expect: () => [
      HistoryState(
        status: HistoryStatus.loading,
        period: CalendarPeriod.month,
        referenceDate: DateTime(2024, 9, 15),
      ),
      HistoryState(
        status: HistoryStatus.loaded,
        period: CalendarPeriod.month,
        referenceDate: DateTime(2024, 9, 15),
        summary: summaryFor(CalendarPeriod.month, DateTime(2024, 9, 15)),
      ),
      HistoryState(
        status: HistoryStatus.loading,
        period: CalendarPeriod.week,
        referenceDate: DateTime(2024, 9, 15),
      ),
      HistoryState(
        status: HistoryStatus.loaded,
        period: CalendarPeriod.week,
        referenceDate: DateTime(2024, 9, 15),
        summary: summaryFor(CalendarPeriod.week, DateTime(2024, 9, 15)),
      ),
    ],
    verify: (_) {
      verify(() => getCalendarSummary(CalendarPeriod.week, DateTime(2024, 9, 15)))
          .called(1);
    },
  );

  blocTest<HistoryCubit, HistoryState>(
    'goToPrevious shifts the reference date back by one period',
    build: () {
      stub(CalendarPeriod.month, DateTime(2024, 9, 15));
      stub(CalendarPeriod.month, DateTime(2024, 8, 15));
      return HistoryCubit(
        getCalendarSummary: getCalendarSummary,
        initialDate: DateTime(2024, 9, 15),
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.goToPrevious();
    },
    verify: (_) {
      verify(() => getCalendarSummary(CalendarPeriod.month, DateTime(2024, 8, 15)))
          .called(1);
    },
  );

  blocTest<HistoryCubit, HistoryState>(
    'goToNext shifts the reference date forward by one period',
    build: () {
      stub(CalendarPeriod.month, DateTime(2024, 9, 15));
      stub(CalendarPeriod.month, DateTime(2024, 10, 15));
      return HistoryCubit(
        getCalendarSummary: getCalendarSummary,
        initialDate: DateTime(2024, 9, 15),
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.goToNext();
    },
    expect: () => [
      HistoryState(
        status: HistoryStatus.loading,
        period: CalendarPeriod.month,
        referenceDate: DateTime(2024, 9, 15),
      ),
      HistoryState(
        status: HistoryStatus.loaded,
        period: CalendarPeriod.month,
        referenceDate: DateTime(2024, 9, 15),
        summary: summaryFor(CalendarPeriod.month, DateTime(2024, 9, 15)),
      ),
      HistoryState(
        status: HistoryStatus.loading,
        period: CalendarPeriod.month,
        referenceDate: DateTime(2024, 10, 15),
      ),
      HistoryState(
        status: HistoryStatus.loaded,
        period: CalendarPeriod.month,
        referenceDate: DateTime(2024, 10, 15),
        summary: summaryFor(CalendarPeriod.month, DateTime(2024, 10, 15)),
      ),
    ],
    verify: (_) {
      verify(() => getCalendarSummary(CalendarPeriod.month, DateTime(2024, 10, 15)))
          .called(1);
    },
  );

  blocTest<HistoryCubit, HistoryState>(
    'jumpToDate reloads for the given date',
    build: () {
      stub(CalendarPeriod.month, DateTime(2024, 9, 15));
      stub(CalendarPeriod.month, DateTime(2024, 1, 1));
      return HistoryCubit(
        getCalendarSummary: getCalendarSummary,
        initialDate: DateTime(2024, 9, 15),
      );
    },
    act: (cubit) async {
      await cubit.load();
      await cubit.jumpToDate(DateTime(2024, 1, 1));
    },
    verify: (_) {
      verify(() => getCalendarSummary(CalendarPeriod.month, DateTime(2024, 1, 1)))
          .called(1);
    },
  );
}

final _sep15 = DateTime(2024, 9, 15);
