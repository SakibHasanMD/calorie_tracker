import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/calendar.dart';
import '../../domain/entities/calorie_target_scope.dart';
import '../../domain/repositories/calorie_target_repository.dart';
import '../datasources/calorie_target_local_datasource.dart';

class CalorieTargetRepositoryImpl implements CalorieTargetRepository {
  CalorieTargetRepositoryImpl({required CalorieTargetLocalDataSource dataSource})
      : _dataSource = dataSource;

  final CalorieTargetLocalDataSource _dataSource;

  @override
  Future<Either<Failure, int>> getTarget(String date) async {
    try {
      final all = await _dataSource.readAll();
      return Right(all[date] ?? CalorieTargetLocalDataSource.defaultTarget);
    } catch (_) {
      return const Left(
        CacheFailure(message: 'Could not read your calorie target.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setTarget(
    String date,
    int value,
    CalorieTargetScope scope,
  ) async {
    if (value <= 0) {
      return const Left(
        ValidationFailure(message: 'Target must be greater than zero.'),
      );
    }
    try {
      final all = await _dataSource.readAll();
      for (final day in _datesInScope(date, scope)) {
        all[day] = value;
      }
      await _dataSource.writeAll(all);
      return const Right(unit);
    } catch (_) {
      return const Left(
        CacheFailure(message: 'Could not save your calorie target.'),
      );
    }
  }

  /// The `YYYY-MM-DD` days covered by [scope]'s range containing [date].
  static List<String> _datesInScope(String date, CalorieTargetScope scope) {
    final d = _parse(date);
    final days = <String>[];

    switch (scope) {
      case CalorieTargetScope.day:
        days.add(formatYmd(d));
        break;
      case CalorieTargetScope.week:
        // Saturday → Friday.
        final start = weekStart(d);
        for (var i = 0; i < 7; i++) {
          days.add(formatYmd(start.add(Duration(days: i))));
        }
        break;
      case CalorieTargetScope.month:
        final first = DateTime(d.year, d.month, 1);
        final last = DateTime(d.year, d.month + 1, 0);
        for (var day = first; !day.isAfter(last); day = day.add(const Duration(days: 1))) {
          days.add(formatYmd(day));
        }
        break;
      case CalorieTargetScope.year:
        for (var month = 1; month <= 12; month++) {
          final first = DateTime(d.year, month, 1);
          final last = DateTime(d.year, month + 1, 0);
          for (var day = first; !day.isAfter(last); day = day.add(const Duration(days: 1))) {
            days.add(formatYmd(day));
          }
        }
        break;
    }
    return days;
  }

  static DateTime _parse(String yyyyMmDd) {
    final parts = yyyyMmDd.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}