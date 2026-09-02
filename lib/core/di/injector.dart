import 'package:get_it/get_it.dart';

import '../../features/food_catalog/data/datasources/food_catalog_local_asset_datasource.dart';
import '../../features/food_catalog/data/datasources/food_catalog_persisted_datasource.dart';
import '../../features/food_catalog/data/repositories/food_catalog_repository_impl.dart';
import '../../features/food_catalog/domain/repositories/food_catalog_repository.dart';
import '../../features/food_catalog/domain/usecases/add_custom_food.dart';
import '../../features/food_catalog/domain/usecases/delete_custom_food.dart';
import '../../features/food_catalog/domain/usecases/get_all_foods.dart';
import '../../features/food_catalog/domain/usecases/update_custom_food.dart';
import '../../features/food_catalog/presentation/cubit/food_catalog_cubit.dart';

/// Central dependency injection container.
///
/// Data sources and repositories are registered as `lazySingleton` (one shared
/// instance — they hold state like the open DB / cache). Cubits are registered
/// as `factory` so a fresh instance is created per screen. Registrations are
/// grouped by feature with a comment header per block. Register repositories
/// before cubits so lazy resolution can depend on them.
abstract final class Injector {
  static final GetIt getIt = GetIt.instance;

  /// Must be called exactly once, from `main()`, before `runApp`.
  static void setupLocator() {
    // ------------------------------------------------------------------
    // Track 1 — Core & Foundation
    // (No feature registrations yet — this track is pure infrastructure.)
    // ------------------------------------------------------------------

    // ------------------------------------------------------------------
    // Track 2 — Food Catalog
    // ------------------------------------------------------------------
    getIt
      ..registerLazySingleton<FoodCatalogLocalAssetDataSource>(
        FoodCatalogLocalAssetDataSource.new,
      )
      ..registerLazySingleton<FoodCatalogPersistedDataSource>(
        FoodCatalogPersistedDataSource.new,
      )
      ..registerLazySingleton<FoodCatalogRepository>(
        () => FoodCatalogRepositoryImpl(
          localAssetDataSource: getIt<FoodCatalogLocalAssetDataSource>(),
          persistedDataSource: getIt<FoodCatalogPersistedDataSource>(),
        ),
      )
      ..registerLazySingleton<GetAllFoods>(
        () => GetAllFoods(repository: getIt<FoodCatalogRepository>()),
      )
      ..registerLazySingleton<AddCustomFood>(
        () => AddCustomFood(repository: getIt<FoodCatalogRepository>()),
      )
      ..registerLazySingleton<UpdateCustomFood>(
        () => UpdateCustomFood(repository: getIt<FoodCatalogRepository>()),
      )
      ..registerLazySingleton<DeleteCustomFood>(
        () => DeleteCustomFood(repository: getIt<FoodCatalogRepository>()),
      )
      ..registerFactory<FoodCatalogCubit>(
        () => FoodCatalogCubit(
          getAllFoods: getIt<GetAllFoods>(),
          addCustomFood: getIt<AddCustomFood>(),
          updateCustomFood: getIt<UpdateCustomFood>(),
          deleteCustomFood: getIt<DeleteCustomFood>(),
        ),
      );
  }
}