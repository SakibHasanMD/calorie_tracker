import 'package:calorie_tracker/features/diary/domain/entities/diary_entry.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:calorie_tracker/features/statistics/domain/usecases/calculate_statistics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Reference "today" is a Thursday.
  final now = DateTime(2024, 9, 26);
  const calculator = CalculateStatistics();

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

  group('totals', () {
    test('computes today, this-week, this-month and all-time totals', () {
      final stats = calculator(
        [
          // Today (Thu 2024-09-26)
          entry(date: '2024-09-26', calories: 100),
          entry(date: '2024-09-26', calories: 50),
          // This week (Mon 09-23 .. Sun 09-29)
          entry(date: '2024-09-24', calories: 200),
          entry(date: '2024-09-27', calories: 75),
          // This month (Sep)
          entry(date: '2024-09-05', calories: 300),
          entry(date: '2024-09-30', calories: 25),
          // Earlier this year
          entry(date: '2024-01-15', calories: 400),
          // Old entry outside any window
          entry(date: '2023-11-02', calories: 999),
        ],
        now: now,
      );

      expect(stats.referenceDate, DateTime(2024, 9, 26));
      expect(stats.todayCalories, 150);
      // Mon 23 + Tue 24 + Wed 25 + Thu 26 + Fri 27 within week.
      expect(stats.weekCalories, 200 + 75 + 150);
      expect(stats.monthCalories, 300 + 25 + 200 + 75 + 150);
      // All time includes the 2023 entry too.
      expect(stats.allTimeCalories, 150 + 200 + 75 + 300 + 25 + 400 + 999);
    });
  });

  group('averages', () {
    test('7-day average sums the trailing 7 days / 7', () {
      final stats = calculator(
        [
          entry(date: '2024-09-26', calories: 700), // today
          entry(date: '2024-09-24', calories: 140), // inside last 7 days
          entry(date: '2024-09-19', calories: 630), // outside last 7 days
        ],
        now: now,
      );
      // last7 = Sep 20..26; only Sep 26 + Sep 24 count (700 + 140).
      expect(stats.sevenDayAverage, closeTo((700 + 140) / 7, 0.0001));
    });

    test('30-day average fractions across exactly 30 days', () {
      final stats = calculator(
        [entry(date: '2024-09-26', calories: 300)],
        now: now,
      );
      expect(stats.thirtyDayAverage, closeTo(10, 0.0001));
    });
  });

  group('edge cases', () {
    test('no entries at all yields zero everywhere', () {
      final stats = calculator(const [], now: now);
      expect(stats.todayCalories, 0);
      expect(stats.weekCalories, 0);
      expect(stats.monthCalories, 0);
      expect(stats.allTimeCalories, 0);
      expect(stats.sevenDayAverage, 0);
      expect(stats.thirtyDayAverage, 0);
    });

    test('entries exactly on the 7-day boundary are included', () {
      // boundary = today - 6 = Sep 20 (included).
      final stats = calculator(
        [entry(date: '2024-09-20', calories: 70)],
        now: now,
      );
      expect(stats.sevenDayAverage, closeTo(70 / 7, 0.0001));
    });

    test('an entry just outside the trailing window is excluded from averages',
        () {
      // today - 7 = Sep 19 (excluded from 7-day).
      final stats = calculator(
        [entry(date: '2024-09-19', calories: 70)],
        now: now,
      );
      expect(stats.sevenDayAverage, 0);
      // Still within 30-day window (Sep 19 >= Aug 28).
      expect(stats.thirtyDayAverage, closeTo(70 / 30, 0.0001));
    });
  });
}
