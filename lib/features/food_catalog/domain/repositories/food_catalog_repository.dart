import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/food.dart';

/// Abstract interface for the food catalog'data operations.
abstract interface class FoodCatalogRepository {
  /// Returns all foods (seeded + custom), seeding the persisted cache on first
  /// launch if needed.
  Future<Either<Failure, List<Food>>> getAllFoods();

  /// Filters the catalog (by name/category, case-insensitive) to [query].
  Future<Either<Failure, List<Food>>> searchFoods(String query);

  /// Adds a user-created food to the catalog.
  Future<Either<Failure, Food>> addCustomFood(Food food);

  /// Updates an existing custom food. Fails for non-custom foods.
  Future<Either<Failure, Food>> updateCustomFood(Food food);

  /// Deletes a user-created food by [id]. Fails for non-custom foods.
  Future<Either<Failure, Unit>> deleteCustomFood(String id);
}