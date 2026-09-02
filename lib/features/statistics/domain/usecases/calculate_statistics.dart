import '../../../diary/domain/entities/diary_entry.dart';
import '../../../../core/utils/calendar.dart';
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
    final today = dateOnly(now ?? DateTime.now());
    // "This week" follows the app's locale convention: Saturday → Friday.
    final weekStartDay = weekStart(today);
    final weekEndDay = weekEnd(today);
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
      if (!d.isBefore(weekStartDay) && !d.isAfter(weekEndDay)) {
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
}
