// Shared mocktail mock classes, centralized so each test file re-uses them
// instead of redeclaring a mock per file.
import 'package:calorie_tracker/features/diary/domain/repositories/diary_repository.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/add_diary_entry.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/get_entries_for_date.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/get_entries_for_range.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/get_recent_foods.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/update_diary_entry.dart';
import 'package:calorie_tracker/features/food_catalog/data/datasources/food_catalog_local_asset_datasource.dart';
import 'package:calorie_tracker/features/food_catalog/data/datasources/food_catalog_persisted_datasource.dart';
import 'package:calorie_tracker/features/food_catalog/domain/repositories/food_catalog_repository.dart';
import 'package:calorie_tracker/features/food_catalog/domain/usecases/add_custom_food.dart';
import 'package:calorie_tracker/features/food_catalog/domain/usecases/delete_custom_food.dart';
import 'package:calorie_tracker/features/food_catalog/domain/usecases/get_all_foods.dart';
import 'package:calorie_tracker/features/food_catalog/domain/usecases/update_custom_food.dart';
import 'package:calorie_tracker/features/home/data/datasources/calorie_target_local_datasource.dart';
import 'package:calorie_tracker/features/home/domain/repositories/calorie_target_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodCatalogRepository extends Mock
    implements FoodCatalogRepository {}

class MockFoodCatalogLocalAssetDataSource extends Mock
    implements FoodCatalogLocalAssetDataSource {}

class MockFoodCatalogPersistedDataSource extends Mock
    implements FoodCatalogPersistedDataSource {}

class MockGetAllFoods extends Mock implements GetAllFoods {}

class MockAddCustomFood extends Mock implements AddCustomFood {}

class MockUpdateCustomFood extends Mock implements UpdateCustomFood {}

class MockDeleteCustomFood extends Mock implements DeleteCustomFood {}

class MockDiaryRepository extends Mock implements DiaryRepository {}

class MockAddDiaryEntry extends Mock implements AddDiaryEntry {}

class MockUpdateDiaryEntry extends Mock implements UpdateDiaryEntry {}

class MockGetEntriesForDate extends Mock implements GetEntriesForDate {}

class MockGetEntriesForRange extends Mock implements GetEntriesForRange {}

class MockGetRecentFoods extends Mock implements GetRecentFoods {}

class MockCalorieTargetRepository extends Mock
    implements CalorieTargetRepository {}

class MockCalorieTargetLocalDataSource extends Mock
    implements CalorieTargetLocalDataSource {}
