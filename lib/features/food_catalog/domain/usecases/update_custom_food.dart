import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/food.dart';
import '../../domain/repositories/food_catalog_repository.dart';

/// Updates an existing custom food.
class UpdateCustomFood {
  const UpdateCustomFood({required FoodCatalogRepository repository})
      : _repository = repository;

  final FoodCatalogRepository _repository;

  Future<Either<Failure, Food>> call(Food food) =>
      _repository.updateCustomFood(food);
}