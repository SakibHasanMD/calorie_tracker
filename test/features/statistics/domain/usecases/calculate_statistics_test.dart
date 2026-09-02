import 'package:calorie_tracker/features/diary/domain/entities/diary_entry.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:calorie_tracker/features/statistics/domain/usecases/calculate_statistics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Reference "today" is a Thursday.
  final now = DateTime(2024, 9, 26);
  const calculator = CalculateStatistics();
  const defaultTarget = 2000;

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
          // This week (Sat 09-21 .. Fri 09-27)
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
        defaultTarget: defaultTarget,
        storedTargets: const {},
        now: now,
      );

      expect(stats.referenceDate, DateTime(2024, 9, 26));
      expect(stats.todayCalories, 150);
      // "This week" follows Sat-Fri convention; Sat Sep 21..Fri Sep 27.
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
        defaultTarget: defaultTarget,
        storedTargets: const {},
        now: now,
      );
      // last7 = Sep 20..26; only Sep 26 + Sep 24 count (700 + 140).
      expect(stats.sevenDayAverage, closeTo((700 + 140) / 7, 0.0001));
    });

    test('30-day average fractions across exactly 30 days', () {
      final stats = calculator(
        [entry(date: '2024-09-26', calories: 300)],
        defaultTarget: defaultTarget,
        storedTargets: const {},
        now: now,
      );
      expect(stats.thirtyDayAverage, closeTo(10, 0.0001));
    });
  });

  group('edge cases', () {
    test('no entries at all yields zero everywhere', () {
      final stats = calculator(
        const [],
        defaultTarget: defaultTarget,
        storedTargets: const {},
        now: now,
      );
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
        defaultTarget: defaultTarget,
        storedTargets: const {},
        now: now,
      );
      expect(stats.sevenDayAverage, closeTo(70 / 7, 0.0001));
    });

    test('an entry just outside the trailing window is excluded from averages',
        () {
      // today - 7 = Sep 19 (excluded from 7-day).
      final stats = calculator(
        [entry(date: '2024-09-19', calories: 70)],
        defaultTarget: defaultTarget,
        storedTargets: const {},
        now: now,
      );
      expect(stats.sevenDayAverage, 0);
      // Still within 30-day window (Sep 19 >= Aug 28).
      expect(stats.thirtyDayAverage, closeTo(70 / 30, 0.0001));
    });
  });

  group('per-period targets', () {
    test('defaults to 2000 per day when no targets are stored', () {
      final stats = calculator(
        [entry(date: '2024-09-26', calories: 100)],
        defaultTarget: defaultTarget,
        storedTargets: const {},
        now: now,
      );
      expect(stats.todayTarget, 2000);
      // Sat Sep 21..Fri Sep 27 = 7 days × 2000.
      expect(stats.weekTarget, 14000);
      // September 2024 = 30 days × 2000.
      expect(stats.monthTarget, 60000);
      // All time is 1 distinct day × 2000.
      expect(stats.allTimeTarget, 2000);
    });

    test('uses stored targets for days in the period', () {
      // Two days in this month: Sep 26 has a stored 1800 target.
      final stats = calculator(
        [
          entry(date: '2024-09-26', calories: 1900),
          entry(date: '2024-09-21', calories: 2500),
        ],
        defaultTarget: defaultTarget,
        storedTargets: const {'2024-09-26': 1800},
        now: now,
      );
      expect(stats.todayTarget, 1800);
      // Sat Sep 21..Fri Sep 27 = 7 days: Sep 21 + Sep 26 are 2000 each, plus
      // a stored 1800 for Sep 26 (overrides), so 6 × 2000 + 1800 = 13800.
      expect(stats.weekTarget, 6 * 2000 + 1800);
      // Month: Sep 21 is 2000, Sep 26 is 1800, other 28 days are 2000.
      expect(stats.monthTarget, 28 * 2000 + 2000 + 1800);
      // All time: 2 distinct days, one with 1800, one default 2000.
      expect(stats.allTimeTarget, 1800 + 2000);
    });
  });
}
