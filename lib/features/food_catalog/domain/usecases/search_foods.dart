import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/food.dart';
import '../../domain/repositories/food_catalog_repository.dart';

/// Filters the food catalog by a query string.
class SearchFoods {
  const SearchFoods({required FoodCatalogRepository repository})
      : _repository = repository;

  final FoodCatalogRepository _repository;

  Future<Either<Failure, List<Food>>> call(String query) =>
      _repository.searchFoods(query);
}