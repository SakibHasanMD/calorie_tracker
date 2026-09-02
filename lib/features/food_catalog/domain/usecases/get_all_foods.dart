import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/food.dart';
import '../../domain/repositories/food_catalog_repository.dart';

/// Returns the full food catalog (seeded + custom).
class GetAllFoods {
  const GetAllFoods({required FoodCatalogRepository repository})
      : _repository = repository;

  final FoodCatalogRepository _repository;

  Future<Either<Failure, List<Food>>> call() => _repository.getAllFoods();
}