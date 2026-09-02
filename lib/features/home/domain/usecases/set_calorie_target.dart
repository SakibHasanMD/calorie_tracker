import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/calorie_target_scope.dart';
import '../repositories/calorie_target_repository.dart';

/// Sets the daily calorie target for [date], applying to the full [scope]
/// range that contains it (day / Sat-Fri week / calendar month / year).
class SetCalorieTarget {
  const SetCalorieTarget({required CalorieTargetRepository repository})
      : _repository = repository;

  final CalorieTargetRepository _repository;

  Future<Either<Failure, Unit>> call(
    String date,
    int value,
    CalorieTargetScope scope,
  ) =>
      _repository.setTarget(date, value, scope);
}