import 'package:bloc_test/bloc_test.dart';
import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/entities/diary_entry.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/get_entries_for_date.dart';
import 'package:calorie_tracker/features/diary/presentation/cubit/daily_diary_cubit.dart';
import 'package:calorie_tracker/features/diary/presentation/cubit/daily_diary_state.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockGetEntriesForDate getEntriesForDate;

  setUp(() {
    getEntriesForDate = MockGetEntriesForDate();
  });

  DiaryEntry make({
    int? id,
    double calories = 100,
    String entryDate = '2024-09-15',
  }) =>
      DiaryEntry(
        id: id ?? 1,
        foodId: 'f1',
        foodName: 'Food',
        measurementType: MeasurementType.gram,
        amount: 100,
        calories: calories,
        entryDate: entryDate,
        createdAt: DateTime(2024, 9, 15),
        updatedAt: DateTime(2024, 9, 15),
      );

  blocTest<DailyDiaryCubit, DailyDiaryState>(
    'load emits loading then loaded with computed total',
    build: () {
      when(() => getEntriesForDate('2024-09-15')).thenAnswer(
        (_) async => Right([make(calories: 200), make(calories: 300)]),
      );
      return DailyDiaryCubit(getEntriesForDate: getEntriesForDate);
    },
    act: (cubit) => cubit.load('2024-09-15'),
    expect: () => [
      const DailyDiaryState(
        status: DailyDiaryStatus.loading,
        date: '2024-09-15',
      ),
      DailyDiaryState(
        status: DailyDiaryStatus.loaded,
        date: '2024-09-15',
        entries: [make(calories: 200), make(calories: 300)],
        totalCalories: 500,
      ),
    ],
  );

  blocTest<DailyDiaryCubit, DailyDiaryState>(
    'load emits loading then error on failure',
    build: () {
      when(() => getEntriesForDate('2024-09-15')).thenAnswer(
        (_) async => const Left(CacheFailure(message: 'oops')),
      );
      return DailyDiaryCubit(getEntriesForDate: getEntriesForDate);
    },
    act: (cubit) => cubit.load('2024-09-15'),
    expect: () => [
      const DailyDiaryState(
        status: DailyDiaryStatus.loading,
        date: '2024-09-15',
      ),
      const DailyDiaryState(
        status: DailyDiaryStatus.error,
        date: '2024-09-15',
        entries: [],
        totalCalories: 0,
        failure: CacheFailure(message: 'oops'),
      ),
    ],
  );

  test('setEntries replaces the list and recomputes the total', () {
    final cubit = DailyDiaryCubit(getEntriesForDate: getEntriesForDate);
    cubit.setEntries([make(calories: 100), make(calories: 50)]);
    expect(cubit.state.status, DailyDiaryStatus.loaded);
    expect(cubit.state.entries.length, 2);
    expect(cubit.state.totalCalories, 150);
    cubit.close();
  });
}
