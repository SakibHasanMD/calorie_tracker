import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/repositories/food_catalog_repository.dart';

/// Deletes a user-created food by id.
class DeleteCustomFood {
  const DeleteCustomFood({required FoodCatalogRepository repository})
      : _repository = repository;

  final FoodCatalogRepository _repository;

  Future<Either<Failure, Unit>> call(String id) =>
      _repository.deleteCustomFood(id);
}