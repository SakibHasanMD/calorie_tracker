import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/calorie_target_repository.dart';

/// Reads the user's daily calorie target.
class GetCalorieTarget {
  const GetCalorieTarget({required CalorieTargetRepository repository})
      : _repository = repository;

  final CalorieTargetRepository _repository;

  Future<Either<Failure, int>> call() => _repository.getTarget();
}
