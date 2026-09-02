import 'package:equatable/equatable.dart';

/// The set of calorie statistics shown on the Statistics screen.
class Statistics extends Equatable {
  const Statistics({
    required this.referenceDate,
    required this.todayCalories,
    required this.todayTarget,
    required this.weekCalories,
    required this.weekTarget,
    required this.monthCalories,
    required this.monthTarget,
    required this.allTimeCalories,
    required this.allTimeTarget,
    required this.sevenDayAverage,
    required this.thirtyDayAverage,
  });

  /// The "today" these statistics are computed against (so tests and the UI
  /// agree on what today is).
  final DateTime referenceDate;

  final double todayCalories;
  final int todayTarget;

  /// Total for the Sat-Fri week containing [referenceDate].
  final double weekCalories;
  final int weekTarget;

  /// Total for the calendar month containing [referenceDate].
  final double monthCalories;
  final int monthTarget;

  final double allTimeCalories;
  final int allTimeTarget;

  /// Average daily intake over the trailing 7 days (including today).
  final double sevenDayAverage;

  /// Average daily intake over the trailing 30 days (including today).
  final double thirtyDayAverage;

  @override
  List<Object?> get props => [
        referenceDate,
        todayCalories,
        todayTarget,
        weekCalories,
        weekTarget,
        monthCalories,
        monthTarget,
        allTimeCalories,
        allTimeTarget,
        sevenDayAverage,
        thirtyDayAverage,
      ];
}
