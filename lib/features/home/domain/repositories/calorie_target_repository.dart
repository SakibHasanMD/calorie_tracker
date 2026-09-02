import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

/// Reads/writes the user's daily calorie target.
///
/// Lives in the `home` feature because it is a Home-only preference (not a
/// full settings feature). Domain layer; implementations live in `data` and
/// surface exceptions as [Failure]s.
abstract interface class CalorieTargetRepository {
  Future<Either<Failure, int>> getTarget();

  Future<Either<Failure, Unit>> setTarget(int value);
}

