import 'package:equatable/equatable.dart';

/// The granularity of a calendar summary view.
enum CalendarPeriod { day, week, month, year }

/// One bucket in a [CalendarSummary].
///
/// Buckets are always contiguous within the summary's range (the date range
/// is fully covered, including buckets with zero calories). [date] is the
/// first day of the bucket: the day itself for `day`/`week`/`month` views,
/// and the first day of each month for the `year` view.
class CalendarBucket extends Equatable {
  const CalendarBucket({required this.date, required this.calories});

  /// First day of this bucket (local, midnight).
  final DateTime date;

  /// Sum of calories across the entries that fall in this bucket.
  final double calories;

  @override
  List<Object?> get props => [date, calories];
}

/// The fully-bucketed summary for a single period.
///
/// The [buckets] list covers the whole span from [startDate] to [endDate]
/// (inclusive), so empty days/months still appear with `calories == 0` — the
/// History UI can render an empty period without special-casing missing days.
class CalendarSummary extends Equatable {
  const CalendarSummary({
    required this.period,
    required this.referenceDate,
    required this.startDate,
    required this.endDate,
    required this.totalCalories,
    required this.buckets,
  });

  final CalendarPeriod period;

  /// The date the user is currently viewing (not necessarily the range start).
  final DateTime referenceDate;

  /// Inclusive `YYYY-MM-DD` range passed to `getEntriesForRange`.
  final String startDate;
  final String endDate;

  final double totalCalories;

  final List<CalendarBucket> buckets;

  @override
  List<Object?> get props => [
        period,
        referenceDate,
        startDate,
        endDate,
        totalCalories,
        buckets,
      ];
}
