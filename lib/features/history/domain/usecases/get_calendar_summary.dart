import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/calendar.dart';
import '../../../diary/domain/entities/diary_entry.dart';
import '../../../diary/domain/usecases/get_entries_for_range.dart';
import '../entities/calendar_summary.dart';

/// Builds a bucketed calorie summary for a [CalendarPeriod] around a
/// reference date.
///
/// Computes the inclusive `[startDate, endDate]` range for the period, reads
/// the entries in that range through the diary `GetEntriesForRange` usecase,
/// then buckets/sums them. The returned [CalendarSummary] covers the entire
/// span (zero-calorie buckets included), so the UI can render an empty period
/// cleanly.
class GetCalendarSummary {
  const GetCalendarSummary({required GetEntriesForRange getEntriesForRange})
      : _getEntriesForRange = getEntriesForRange;

  final GetEntriesForRange _getEntriesForRange;

  Future<Either<Failure, CalendarSummary>> call(
    CalendarPeriod period,
    DateTime referenceDate,
  ) async {
    final range = _rangeFor(period, referenceDate);
    final result = await _getEntriesForRange(range.start, range.end);
    return result.fold(
      (failure) => Left(failure),
      (entries) => Right(
        _buildSummary(
          period: period,
          referenceDate: referenceDate,
          start: range.start,
          end: range.end,
          entries: entries,
        ),
      ),
    );
  }

  CalendarSummary _buildSummary({
    required CalendarPeriod period,
    required DateTime referenceDate,
    required String start,
    required String end,
    required List<DiaryEntry> entries,
  }) {
    // Group calories by day (day/week/month views) or by month (year view).
    final totals = <DateTime, double>{};
    for (final entry in entries) {
      final key = period == CalendarPeriod.year
          ? _firstOfMonth(entry.entryDateAsDateTime)
          : entry.entryDateAsDateTime;
      totals.update(key, (v) => v + entry.calories, ifAbsent: () => entry.calories);
    }

    final buckets = <CalendarBucket>[];
    var total = 0.0;

    if (period == CalendarPeriod.year) {
      final firstMonth = DateTime(referenceDate.year, 1, 1);
      final lastMonth = DateTime(referenceDate.year, 12, 1);
      var d = firstMonth;
      while (!d.isAfter(lastMonth)) {
        final monthTotal = totals[d] ?? 0;
        total += monthTotal;
        buckets.add(CalendarBucket(date: d, calories: monthTotal));
        d = d.month == 12
            ? DateTime(d.year + 1, 1, 1)
            : DateTime(d.year, d.month + 1, 1);
      }
    } else {
      // day / week / month all bucket per-day across the period's span.
      final cursor = period == CalendarPeriod.week
          ? weekStart(referenceDate)
          : period == CalendarPeriod.month
              ? DateTime(referenceDate.year, referenceDate.month, 1)
              : dateOnly(referenceDate);
      final last = period == CalendarPeriod.day
          ? cursor
          : period == CalendarPeriod.week
              ? cursor.add(const Duration(days: 6))
              : DateTime(referenceDate.year, referenceDate.month + 1, 0);
      var d = cursor;
      while (!d.isAfter(last)) {
        final dayTotal = totals[d] ?? 0;
        total += dayTotal;
        buckets.add(CalendarBucket(date: d, calories: dayTotal));
        d = d.add(const Duration(days: 1));
      }
    }

    return CalendarSummary(
      period: period,
      referenceDate: dateOnly(referenceDate),
      startDate: start,
      endDate: end,
      totalCalories: total,
      buckets: buckets,
    );
  }

  /// Returns the inclusive `YYYY-MM-DD` range string for [period] around
  /// [referenceDate] plus those same strings for the range computation.
  ({String start, String end}) _rangeFor(
    CalendarPeriod period,
    DateTime referenceDate,
  ) {
    final r = dateOnly(referenceDate);
    switch (period) {
      case CalendarPeriod.day:
        final s = formatYmd(r);
        return (start: s, end: s);
      case CalendarPeriod.week:
        final sat = weekStart(r);
        final fri = sat.add(const Duration(days: 6));
        return (start: formatYmd(sat), end: formatYmd(fri));
      case CalendarPeriod.month:
        final first = DateTime(r.year, r.month, 1);
        final last = DateTime(r.year, r.month + 1, 0);
        return (start: formatYmd(first), end: formatYmd(last));
      case CalendarPeriod.year:
        final first = DateTime(r.year, 1, 1);
        final last = DateTime(r.year, 12, 31);
        return (start: formatYmd(first), end: formatYmd(last));
    }
  }

  static DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month, 1);
}
