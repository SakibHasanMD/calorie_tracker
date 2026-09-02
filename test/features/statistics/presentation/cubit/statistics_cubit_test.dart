import 'package:bloc_test/bloc_test.dart';
import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/entities/diary_entry.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:calorie_tracker/features/statistics/domain/entities/statistics.dart';
import 'package:calorie_tracker/features/statistics/domain/usecases/calculate_statistics.dart';
import 'package:calorie_tracker/features/statistics/presentation/cubit/statistics_cubit.dart';
import 'package:calorie_tracker/features/statistics/presentation/cubit/statistics_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockGetEntriesForRange getEntriesForRange;
  final now = DateTime(2024, 9, 26);

  setUp(() {
    getEntriesForRange = MockGetEntriesForRange();
  });

  DiaryEntry entry({required String date, required double calories}) =>
      DiaryEntry(
        id: 1,
        foodId: 'f1',
        foodName: 'Rice',
        measurementType: MeasurementType.gram,
        amount: 100,
        calories: calories,
        entryDate: date,
        createdAt: DateTime.parse(date),
        updatedAt: DateTime.parse(date),
      );

  StatisticsCubit build() => StatisticsCubit(
        getEntriesForRange: getEntriesForRange,
        calculateStatistics: const CalculateStatistics(),
        now: now,
      );

  blocTest<StatisticsCubit, StatisticsState>(
    'load emits loading then loaded with computed statistics',
    build: () {
      when(() => getEntriesForRange('1970-01-01', '2100-12-31')).thenAnswer(
        (_) async => Right([
          entry(date: '2024-09-26', calories: 100),
          entry(date: '2024-09-24', calories: 200),
          entry(date: '2024-01-15', calories: 400),
        ]),
      );
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const StatisticsState(status: StatisticsStatus.loading),
      StatisticsState(
        status: StatisticsStatus.loaded,
        statistics: Statistics(
          referenceDate: DateTime(2024, 9, 26),
          todayCalories: 100,
          weekCalories: 300, // 100 + 200
          monthCalories: 300,
          allTimeCalories: 700,
          sevenDayAverage: 300 / 7,
          thirtyDayAverage: 300 / 30,
        ),
      ),
    ],
  );

  blocTest<StatisticsCubit, StatisticsState>(
    'load emits loading then error on failure',
    build: () {
      when(() => getEntriesForRange('1970-01-01', '2100-12-31'))
          .thenAnswer((_) async => const Left(CacheFailure(message: 'oops')));
      return build();
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const StatisticsState(status: StatisticsStatus.loading),
      const StatisticsState(
        status: StatisticsStatus.error,
        failure: CacheFailure(message: 'oops'),
      ),
    ],
  );
}
