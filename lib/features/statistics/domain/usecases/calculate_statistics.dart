import '../../../diary/domain/entities/diary_entry.dart';
import '../entities/statistics.dart';

/// Pure, dependency-free calorie statistics computation.
///
/// Takes the full list of diary entries and a reference "today", and returns
/// the six headline numbers. Kept as pure logic (no I/O) so it is trivially
/// unit-testable; the statistics cubit fetches entries and delegates here.
class CalculateStatistics {
  const CalculateStatistics();

  Statistics call(
    List<DiaryEntry> entries, {
    DateTime? now,
  }) {
    final today = _dateOnly(now ?? DateTime.now());
    final weekStart = _startOfWeek(today);
    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 0);

    var todayCalories = 0.0;
    var weekCalories = 0.0;
    var monthCalories = 0.0;
    var allTimeCalories = 0.0;

    // Trailing 7-day and 30-day windows (inclusive of today).
    final last7 = today.subtract(const Duration(days: 6));
    final last30 = today.subtract(const Duration(days: 29));
    var last7Calories = 0.0;
    var last30Calories = 0.0;

    for (final entry in entries) {
      final d = entry.entryDateAsDateTime;
      allTimeCalories += entry.calories;

      if (d == today) todayCalories += entry.calories;
      // "This week" = the full Mon-Sun calendar week; "this month" = the full
      // calendar month. Trailing averages below look only backward.
      if (!d.isBefore(weekStart) && !d.isAfter(weekStart.add(const Duration(days: 6)))) {
        weekCalories += entry.calories;
      }
      if (!d.isBefore(monthStart) && !d.isAfter(monthEnd)) {
        monthCalories += entry.calories;
      }
      if (!d.isBefore(last7) && !d.isAfter(today)) last7Calories += entry.calories;
      if (!d.isBefore(last30) && !d.isAfter(today)) last30Calories += entry.calories;
    }

    return Statistics(
      referenceDate: today,
      todayCalories: todayCalories,
      weekCalories: weekCalories,
      monthCalories: monthCalories,
      allTimeCalories: allTimeCalories,
      sevenDayAverage: last7Calories / 7,
      thirtyDayAverage: last30Calories / 30,
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _startOfWeek(DateTime date) {
    final day = date.weekday; // 1 = Monday ... 7 = Sunday
    return _dateOnly(date).subtract(Duration(days: day - 1));
  }
}
