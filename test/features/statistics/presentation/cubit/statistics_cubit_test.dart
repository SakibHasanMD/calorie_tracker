import 'package:bloc_test/bloc_test.dart';
import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/entities/diary_entry.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:calorie_tracker/features/home/data/datasources/calorie_target_local_datasource.dart';
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
  late MockCalorieTargetLocalDataSource calorieTargetLocalDataSource;
  final now = DateTime(2024, 9, 26);

  setUp(() {
    getEntriesForRange = MockGetEntriesForRange();
    calorieTargetLocalDataSource = MockCalorieTargetLocalDataSource();
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
        calorieTargetLocalDataSource: calorieTargetLocalDataSource,
        now: now,
      );

  blocTest<StatisticsCubit, StatisticsState>(
    'load emits loading then loaded with computed statistics (incl. targets)',
    build: () {
      when(() => getEntriesForRange('1970-01-01', '2100-12-31')).thenAnswer(
        (_) async => Right([
          entry(date: '2024-09-26', calories: 100),
          entry(date: '2024-09-24', calories: 200),
          entry(date: '2024-01-15', calories: 400),
        ]),
      );
      when(() => calorieTargetLocalDataSource.readAll())
          .thenAnswer((_) async => const {'2024-09-26': 1800});
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
          todayTarget: 1800, // stored
          weekCalories: 300,
          // Sat Sep 21..Fri Sep 27 = 7 days: Sep 26 is stored 1800,
          // others default 2000 → 6*2000 + 1800.
          weekTarget: 6 * 2000 + 1800,
          monthCalories: 300,
          // September = 30 days: Sep 26 stored 1800, others 2000.
          monthTarget: 29 * 2000 + 1800,
          allTimeCalories: 700,
          // 3 distinct days: Sep 26 stored 1800, others default.
          allTimeTarget: 2 * 2000 + 1800,
          sevenDayAverage: 300 / 7,
          thirtyDayAverage: 300 / 30,
        ),
      ),
    ],
  );

  blocTest<StatisticsCubit, StatisticsState>(
    'load falls back to the default target when the targets file is missing',
    build: () {
      when(() => getEntriesForRange('1970-01-01', '2100-12-31'))
          .thenAnswer((_) async => Right([entry(date: '2024-09-26', calories: 100)]));
      when(() => calorieTargetLocalDataSource.readAll())
          .thenAnswer((_) async => const {});
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
          todayTarget: CalorieTargetLocalDataSource.defaultTarget,
          weekCalories: 100,
          weekTarget: 7 * CalorieTargetLocalDataSource.defaultTarget,
          monthCalories: 100,
          monthTarget: 30 * CalorieTargetLocalDataSource.defaultTarget,
          allTimeCalories: 100,
          allTimeTarget: CalorieTargetLocalDataSource.defaultTarget,
          sevenDayAverage: 100 / 7,
          thirtyDayAverage: 100 / 30,
        ),
      ),
    ],
  );

  blocTest<StatisticsCubit, StatisticsState>(
    'load emits loading then error on failure',
    build: () {
      when(() => getEntriesForRange('1970-01-01', '2100-12-31'))
          .thenAnswer((_) async => const Left(CacheFailure(message: 'oops')));
      when(() => calorieTargetLocalDataSource.readAll())
          .thenAnswer((_) async => const {});
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
