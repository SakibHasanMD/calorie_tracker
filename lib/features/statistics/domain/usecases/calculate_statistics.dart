import '../../../diary/domain/entities/diary_entry.dart';
import '../../../../core/utils/calendar.dart';
import '../entities/statistics.dart';

/// Pure, dependency-free calorie statistics computation.
///
/// Takes the full list of diary entries, a reference "today", and the
/// per-day calorie targets (date → daily target, defaulting for unset days),
/// and returns the six headline numbers plus per-period targets.
class CalculateStatistics {
  const CalculateStatistics();

  Statistics call(
    List<DiaryEntry> entries, {
    required int defaultTarget,
    required Map<String, int> storedTargets,
    DateTime? now,
  }) {
    final today = dateOnly(now ?? DateTime.now());
    final weekStartDay = weekStart(today);
    final weekEndDay = weekEnd(today);
    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 0);

    var todayCalories = 0.0;
    var weekCalories = 0.0;
    var monthCalories = 0.0;
    var allTimeCalories = 0.0;

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
      if (!d.isBefore(last7) && !d.isAfter(today)) {
        last7Calories += entry.calories;
      }
      if (!d.isBefore(last30) && !d.isAfter(today)) {
        last30Calories += entry.calories;
      }
    }

    return Statistics(
      referenceDate: today,
      todayCalories: todayCalories,
      todayTarget: _dayTarget(formatYmd(today), defaultTarget, storedTargets),
      weekCalories: weekCalories,
      weekTarget: _rangeTarget(weekStartDay, weekEndDay, defaultTarget, storedTargets),
      monthCalories: monthCalories,
      monthTarget: _rangeTarget(monthStart, monthEnd, defaultTarget, storedTargets),
      allTimeCalories: allTimeCalories,
      allTimeTarget: _allTimeTarget(entries, defaultTarget, storedTargets),
      sevenDayAverage: last7Calories / 7,
      thirtyDayAverage: last30Calories / 30,
    );
  }

  static int _dayTarget(String date, int defaultTarget, Map<String, int> stored) {
    return stored[date] ?? defaultTarget;
  }

  /// Sum of daily targets for every day in [start]..[end] (inclusive).
  static int _rangeTarget(
    DateTime start,
    DateTime end,
    int defaultTarget,
    Map<String, int> stored,
  ) {
    var sum = 0;
    var d = start;
    while (!d.isAfter(end)) {
      sum += stored[formatYmd(d)] ?? defaultTarget;
      d = d.add(const Duration(days: 1));
    }
    return sum;
  }

  /// Sum of per-day targets for every distinct day that has at least one
  /// entry. Days without a stored target use [defaultTarget].
  static int _allTimeTarget(
    List<DiaryEntry> entries,
    int defaultTarget,
    Map<String, int> stored,
  ) {
    if (entries.isEmpty) return 0;
    var sum = 0;
    final seen = <String>{};
    for (final entry in entries) {
      final date = formatYmd(entry.entryDateAsDateTime);
      if (seen.add(date)) {
        sum += stored[date] ?? defaultTarget;
      }
    }
    return sum;
  }
}
