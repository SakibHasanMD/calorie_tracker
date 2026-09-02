import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/calorie_target_repository.dart';

/// Reads the effective daily calorie target for a specific date.
class GetCalorieTarget {
  const GetCalorieTarget({required CalorieTargetRepository repository})
      : _repository = repository;

  final CalorieTargetRepository _repository;

  /// [date] is `YYYY-MM-DD`; unset dates resolve to the default target.
  Future<Either<Failure, int>> call(String date) => _repository.getTarget(date);
}