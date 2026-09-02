import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/calorie_target_repository.dart';
import '../datasources/calorie_target_local_datasource.dart';

class CalorieTargetRepositoryImpl implements CalorieTargetRepository {
  CalorieTargetRepositoryImpl({required CalorieTargetLocalDataSource dataSource})
      : _dataSource = dataSource;

  final CalorieTargetLocalDataSource _dataSource;

  @override
  Future<Either<Failure, int>> getTarget() async {
    try {
      return Right(await _dataSource.read());
    } catch (_) {
      return const Left(
        CacheFailure(message: 'Could not read your calorie target.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setTarget(int value) async {
    if (value <= 0) {
      return const Left(
        ValidationFailure(message: 'Target must be greater than zero.'),
      );
    }
    try {
      await _dataSource.write(value);
      return const Right(unit);
    } catch (_) {
      return const Left(
        CacheFailure(message: 'Could not save your calorie target.'),
      );
    }
  }
}
