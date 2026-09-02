import 'package:get_it/get_it.dart';

import '../../features/diary/data/datasources/diary_local_datasource.dart';
import '../../features/diary/data/repositories/diary_repository_impl.dart';
import '../../features/diary/domain/repositories/diary_repository.dart';
import '../../features/diary/domain/usecases/add_diary_entry.dart';
import '../../features/diary/domain/usecases/delete_diary_entry.dart';
import '../../features/diary/domain/usecases/get_entries_for_date.dart';
import '../../features/diary/domain/usecases/get_entries_for_range.dart';
import '../../features/diary/domain/usecases/get_recent_foods.dart';
import '../../features/diary/domain/usecases/update_diary_entry.dart';
import '../../features/diary/presentation/cubit/daily_diary_cubit.dart';
import '../../features/food_catalog/data/datasources/food_catalog_local_asset_datasource.dart';
import '../../features/food_catalog/data/datasources/food_catalog_persisted_datasource.dart';
import '../../features/food_catalog/data/repositories/food_catalog_repository_impl.dart';
import '../../features/food_catalog/domain/repositories/food_catalog_repository.dart';
import '../../features/food_catalog/domain/usecases/add_custom_food.dart';
import '../../features/food_catalog/domain/usecases/delete_custom_food.dart';
import '../../features/food_catalog/domain/usecases/get_all_foods.dart';
import '../../features/food_catalog/domain/usecases/update_custom_food.dart';
import '../../features/food_catalog/presentation/cubit/food_catalog_cubit.dart';
import '../../features/home/data/datasources/calorie_target_local_datasource.dart';
import '../../features/home/data/repositories/calorie_target_repository_impl.dart';
import '../../features/home/domain/repositories/calorie_target_repository.dart';
import '../../features/home/domain/usecases/get_calorie_target.dart';
import '../../features/home/domain/usecases/set_calorie_target.dart';
import '../../features/history/domain/usecases/get_calendar_summary.dart';
import '../../features/history/presentation/cubit/history_cubit.dart';
import '../../features/statistics/domain/usecases/calculate_statistics.dart';
import '../../features/statistics/presentation/cubit/statistics_cubit.dart';

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

    // ------------------------------------------------------------------
    // Track 3 — Diary
    // ------------------------------------------------------------------
    getIt
      ..registerLazySingleton<DiaryLocalDataSource>(
        () => DiaryLocalDataSource(),
      )
      ..registerLazySingleton<DiaryRepository>(
        () => DiaryRepositoryImpl(
          localDataSource: getIt<DiaryLocalDataSource>(),
        ),
      )
      ..registerLazySingleton<AddDiaryEntry>(
        () => AddDiaryEntry(repository: getIt<DiaryRepository>()),
      )
      ..registerLazySingleton<UpdateDiaryEntry>(
        () => UpdateDiaryEntry(repository: getIt<DiaryRepository>()),
      )
      ..registerLazySingleton<DeleteDiaryEntry>(
        () => DeleteDiaryEntry(repository: getIt<DiaryRepository>()),
      )
      ..registerLazySingleton<GetEntriesForDate>(
        () => GetEntriesForDate(repository: getIt<DiaryRepository>()),
      )
      ..registerLazySingleton<GetEntriesForRange>(
        () => GetEntriesForRange(repository: getIt<DiaryRepository>()),
      )
      ..registerLazySingleton<GetRecentFoods>(
        () => GetRecentFoods(repository: getIt<DiaryRepository>()),
      )
      ..registerFactory<DailyDiaryCubit>(
        () => DailyDiaryCubit(getEntriesForDate: getIt<GetEntriesForDate>()),
      );

    // ------------------------------------------------------------------
    // Track 4 — Home
    // ------------------------------------------------------------------
    getIt
      ..registerLazySingleton<CalorieTargetLocalDataSource>(
        CalorieTargetLocalDataSource.new,
      )
      ..registerLazySingleton<CalorieTargetRepository>(
        () => CalorieTargetRepositoryImpl(
          dataSource: getIt<CalorieTargetLocalDataSource>(),
        ),
      )
      ..registerLazySingleton<GetCalorieTarget>(
        () => GetCalorieTarget(repository: getIt<CalorieTargetRepository>()),
      )
      ..registerLazySingleton<SetCalorieTarget>(
        () => SetCalorieTarget(repository: getIt<CalorieTargetRepository>()),
      );

    // ------------------------------------------------------------------
    // Track 5 — History
    // ------------------------------------------------------------------
    getIt
      ..registerLazySingleton<GetCalendarSummary>(
        () => GetCalendarSummary(
          getEntriesForRange: getIt<GetEntriesForRange>(),
        ),
      )
      ..registerFactory<HistoryCubit>(
        () => HistoryCubit(getCalendarSummary: getIt<GetCalendarSummary>()),
      );

    // ------------------------------------------------------------------
    // Track 6 — Statistics
    // ------------------------------------------------------------------
    getIt
      ..registerLazySingleton<CalculateStatistics>(
        CalculateStatistics.new,
      )
      ..registerFactory<StatisticsCubit>(
        () => StatisticsCubit(
          getEntriesForRange: getIt<GetEntriesForRange>(),
          calculateStatistics: getIt<CalculateStatistics>(),
        ),
      );
  }
}