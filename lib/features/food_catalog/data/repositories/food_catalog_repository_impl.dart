import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/food.dart';
import '../../domain/repositories/food_catalog_repository.dart';
import '../datasources/food_catalog_local_asset_datasource.dart';
import '../datasources/food_catalog_persisted_datasource.dart';
import '../models/food_model.dart';

/// Orchestrates the food catalog's data sources.
///
/// - On `getAllFoods()`: if the persisted `food_catalog.json` doesn't exist yet
///   (first launch), copy the seed catalog into it, then read from the
///   persisted file going forward; merge in `custom_foods.json` entries.
/// - Custom-food CRUD only ever reads/rewrites `custom_foods.json`.
class FoodCatalogRepositoryImpl implements FoodCatalogRepository {
  FoodCatalogRepositoryImpl({
    required FoodCatalogLocalAssetDataSource localAssetDataSource,
    required FoodCatalogPersistedDataSource persistedDataSource,
    Uuid? uuid,
  })  : _localAssetDataSource = localAssetDataSource,
        _persistedDataSource = persistedDataSource,
        _uuid = uuid ?? const Uuid();

  final FoodCatalogLocalAssetDataSource _localAssetDataSource;
  final FoodCatalogPersistedDataSource _persistedDataSource;
  final Uuid _uuid;

  @override
  Future<Either<Failure, List<Food>>> getAllFoods() async {
    try {
      final catalog = await _loadOrSeedCatalog();
      final custom = await _persistedDataSource.readCustomFoods();
      return Right([...catalog, ...custom]);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Could not load foods.'));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<Food>>> searchFoods(String query) async {
    final result = await getAllFoods();
    return result.map((foods) {
      final q = query.trim().toLowerCase();
      if (q.isEmpty) return foods;
      return foods
          .where((f) =>
              f.name.toLowerCase().contains(q) ||
              f.category.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  Future<Either<Failure, Food>> addCustomFood(Food food) async {
    try {
      if (food.name.trim().isEmpty) {
        return const Left(ValidationFailure(message: 'Food name is required.'));
      }
      final created = _buildNewCustomFood(food);
      final existing = await _persistedDataSource.readCustomFoods();
      final updated = [...existing, created];
      await _persistedDataSource.writeCustomFoods(updated);
      return Right(created);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Could not save food.'));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Food>> updateCustomFood(Food food) async {
    try {
      if (food.name.trim().isEmpty) {
        return const Left(ValidationFailure(message: 'Food name is required.'));
      }
      final existing = await _persistedDataSource.readCustomFoods();
      final index = existing.indexWhere((f) => f.id == food.id);
      if (index == -1 || !existing[index].isCustom) {
        return const Left(
          NotFoundFailure(message: 'Custom food was not found.'),
        );
      }
      final updated = [...existing];
      updated[index] = FoodModel.fromEntity(food);
      await _persistedDataSource.writeCustomFoods(updated);
      return Right(updated[index]);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Could not update food.'));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCustomFood(String id) async {
    try {
      final existing = await _persistedDataSource.readCustomFoods();
      FoodModel? target;
      for (final f in existing) {
        if (f.id == id) {
          target = f;
          break;
        }
      }
      if (target == null || !target.isCustom) {
        return const Left(
          NotFoundFailure(message: 'Custom food was not found.'),
        );
      }
      final updated = existing.where((f) => f.id != id).toList();
      await _persistedDataSource.writeCustomFoods(updated);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Could not delete food.'));
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  /// Returns the persisted catalog, seeding it from the asset source the first
  /// time. After seeding, the persisted file is the only source read.
  Future<List<FoodModel>> _loadOrSeedCatalog() async {
    final exists = await _persistedDataSource.catalogFileExists();
    if (!exists) {
      final seedFoods = await _localAssetDataSource.fetchFoods();
      await _persistedDataSource.writeCatalog(seedFoods);
      return seedFoods;
    }
    return _persistedDataSource.readCatalog();
  }

  /// Builds a persisted [FoodModel] from user input, generating `custom_<uuid>`
  /// id and a `createdAt` timestamp, and forcing `isCustom = true`.
  FoodModel _buildNewCustomFood(Food food) {
    return FoodModel(
      id: 'custom_${_uuid.v4()}',
      name: food.name.trim(),
      category: food.category,
      measurementType: food.measurementType,
      caloriesPerGram: food.caloriesPerGram,
      caloriesPerPiece: food.caloriesPerPiece,
      isCustom: true,
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}