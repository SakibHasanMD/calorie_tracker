import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/calorie_target_repository.dart';

/// Sets the user's daily calorie target.
class SetCalorieTarget {
  const SetCalorieTarget({required CalorieTargetRepository repository})
      : _repository = repository;

  final CalorieTargetRepository _repository;

  Future<Either<Failure, Unit>> call(int value) => _repository.setTarget(value);
}
