import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/food.dart';
import '../../domain/repositories/food_catalog_repository.dart';

/// Adds a user-created food to the catalog.
class AddCustomFood {
  const AddCustomFood({required FoodCatalogRepository repository})
      : _repository = repository;

  final FoodCatalogRepository _repository;

  Future<Either<Failure, Food>> call(Food food) =>
      _repository.addCustomFood(food);
}