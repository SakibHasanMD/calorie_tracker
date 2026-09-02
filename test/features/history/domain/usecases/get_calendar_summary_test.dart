import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/entities/diary_entry.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:calorie_tracker/features/history/domain/entities/calendar_summary.dart';
import 'package:calorie_tracker/features/history/domain/usecases/get_calendar_summary.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockGetEntriesForRange getEntriesForRange;
  late GetCalendarSummary usecase;

  setUp(() {
    getEntriesForRange = MockGetEntriesForRange();
    usecase = GetCalendarSummary(getEntriesForRange: getEntriesForRange);
  });

  DiaryEntry entry(String date, double calories) => DiaryEntry(
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

  group('day', () {
    test('builds a single bucket with the day total', () async {
      when(() => getEntriesForRange('2024-09-15', '2024-09-15')).thenAnswer(
        (_) async => Right([entry('2024-09-15', 300), entry('2024-09-15', 150)]),
      );
      final result =
          await usecase(CalendarPeriod.day, DateTime(2024, 9, 15));

      expect(result.isRight(), isTrue);
      final summary = result.getRight().toNullable()!;
      expect(summary.period, CalendarPeriod.day);
      expect(summary.totalCalories, 450);
      expect(summary.buckets.length, 1);
      expect(summary.buckets.first.calories, 450);
      expect(summary.startDate, '2024-09-15');
      expect(summary.endDate, '2024-09-15');
    });
  });

  group('week', () {
    test('spans a two-month boundary (Mon-Sun) with per-day buckets', () async {
      // Wed 2024-08-28 -> week is Mon 2024-08-26 .. Sun 2024-09-01 (straddles Aug/Sep)
      when(() => getEntriesForRange('2024-08-26', '2024-09-01'))
          .thenAnswer(
            (_) async => Right([
              entry('2024-08-28', 200),
              entry('2024-08-31', 300),
              entry('2024-09-01', 100),
            ]),
          );
      final result =
          await usecase(CalendarPeriod.week, DateTime(2024, 8, 28));

      expect(result.isRight(), isTrue);
      final summary = result.getRight().toNullable()!;
      expect(summary.period, CalendarPeriod.week);
      expect(summary.startDate, '2024-08-26');
      expect(summary.endDate, '2024-09-01');
      expect(summary.buckets.length, 7); // full week
      expect(summary.totalCalories, 600);

      // Map buckets by date.
      final byDay = {for (final b in summary.buckets) _fmt(b.date): b.calories};
      expect(byDay['2024-08-28'], 200);
      expect(byDay['2024-08-31'], 300);
      expect(byDay['2024-09-01'], 100);
      expect(byDay['2024-08-26'], 0); // empty day still present
    });
  });

  group('month', () {
    test('builds one bucket per day in February (leap-aware)', () async {
      final daysInFeb = DateTime(2024, 3, 0).day; // 29
      when(() => getEntriesForRange('2024-02-01', '2024-02-29'))
          .thenAnswer(
            (_) async => Right([entry('2024-02-15', 400)]),
          );
      final result =
          await usecase(CalendarPeriod.month, DateTime(2024, 2, 10));

      expect(result.isRight(), isTrue);
      final summary = result.getRight().toNullable()!;
      expect(summary.buckets.length, daysInFeb);
      expect(summary.totalCalories, 400);
      expect(summary.startDate, '2024-02-01');
      expect(summary.endDate, '2024-02-29');
    });
  });

  group('year', () {
    test('builds one bucket per month and totals by month', () async {
      when(() => getEntriesForRange('2024-01-01', '2024-12-31'))
          .thenAnswer(
            (_) async => Right([
              entry('2024-01-05', 100),
              entry('2024-01-20', 50),
              entry('2024-12-31', 999),
            ]),
          );
      final result =
          await usecase(CalendarPeriod.year, DateTime(2024, 6, 1));

      expect(result.isRight(), isTrue);
      final summary = result.getRight().toNullable()!;
      expect(summary.buckets.length, 12);
      expect(summary.totalCalories, 1149);

      final jan = summary.buckets[0];
      expect(jan.date, DateTime(2024, 1, 1));
      expect(jan.calories, 150);
      expect(summary.buckets[11].calories, 999);
    });
  });

  group('empty period', () {
    test('returns zeroed buckets for a month with no entries', () async {
      when(() => getEntriesForRange('2024-05-01', '2024-05-31'))
          .thenAnswer((_) async => const Right([]));
      final result =
          await usecase(CalendarPeriod.month, DateTime(2024, 5, 15));

      expect(result.isRight(), isTrue);
      final summary = result.getRight().toNullable()!;
      expect(summary.totalCalories, 0);
      expect(summary.buckets.length, 31);
      expect(summary.buckets.every((b) => b.calories == 0), isTrue);
    });
  });

  group('failure', () {
    test('propagates a failure from getEntriesForRange', () async {
      when(() => getEntriesForRange('2024-05-01', '2024-05-31'))
          .thenAnswer((_) async => const Left(CacheFailure(message: 'oops')));
      final result =
          await usecase(CalendarPeriod.month, DateTime(2024, 5, 15));
      expect(result.isLeft(), isTrue);
    });
  });
}

String _fmt(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
