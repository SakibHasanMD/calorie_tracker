import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/calorie_target_scope.dart';

/// Reads/writes date-scoped daily calorie targets.
///
/// Targets are stored per calendar day; setting a target for a scope
/// (day/week/month/year) writes the value to every day in that scope's range,
/// so changing "this month" never rewrites other months. Lives in the `home`
/// feature. Domain layer; implementations live in `data` and surface
/// exceptions as [Failure]s.
abstract interface class CalorieTargetRepository {
  /// The effective target for [date] (`YYYY-MM-DD`), or the default if unset.
  Future<Either<Failure, int>> getTarget(String date);

  /// Sets [value] for every day in [scope]'s range containing [date].
  Future<Either<Failure, Unit>> setTarget(
    String date,
    int value,
    CalorieTargetScope scope,
  );
}