import 'package:equatable/equatable.dart';

/// The set of calorie statistics shown on the Statistics screen.
class Statistics extends Equatable {
  const Statistics({
    required this.referenceDate,
    required this.todayCalories,
    required this.weekCalories,
    required this.monthCalories,
    required this.allTimeCalories,
    required this.sevenDayAverage,
    required this.thirtyDayAverage,
  });

  /// The "today" these statistics are computed against (so tests and the UI
  /// agree on what today is).
  final DateTime referenceDate;

  final double todayCalories;

  /// Total for the Monday-to-Sunday week containing [referenceDate].
  final double weekCalories;

  /// Total for the calendar month containing [referenceDate].
  final double monthCalories;

  final double allTimeCalories;

  /// Average daily intake over the trailing 7 days (including today).
  final double sevenDayAverage;

  /// Average daily intake over the trailing 30 days (including today).
  final double thirtyDayAverage;

  @override
  List<Object?> get props => [
        referenceDate,
        todayCalories,
        weekCalories,
        monthCalories,
        allTimeCalories,
        sevenDayAverage,
        thirtyDayAverage,
      ];
}
