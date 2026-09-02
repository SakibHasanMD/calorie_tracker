import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/json_file_storage.dart';
import '../models/food_model.dart';

/// Manages the two persistent JSON files that back the food catalog:
/// - `food_catalog.json` — a copy of the seed/fetched catalog (read-only,
///   replaceable on refresh)
/// - `custom_foods.json` — user-added foods, never touched by a catalog refresh
class FoodCatalogPersistedDataSource {
  static const String catalogFilename = 'food_catalog.json';
  static const String customFoodsFilename = 'custom_foods.json';

  bool _catalogExistsCache = false;

  /// Whether the persisted catalog file already exists on disk.
  Future<bool> catalogFileExists() async {
    if (_catalogExistsCache) return true;
    final exists = await JsonFileStorage.exists(catalogFilename);
    if (exists) _catalogExistsCache = true;
    return exists;
  }

  /// Reads the persisted catalog. Returns `[]` when the file is missing.
  /// Throws [CacheException] if the file is corrupt.
  Future<List<FoodModel>> readCatalog() async {
    final data = await JsonFileStorage.readJson(catalogFilename);
    if (data == null) return [];
    return _parseList(data);
  }

  /// Writes the whole persisted catalog (replaces it on refresh).
  Future<void> writeCatalog(List<FoodModel> foods) async {
    await JsonFileStorage.writeJson(
      catalogFilename,
      foods.map((f) => f.toJson()).toList(),
    );
    _catalogExistsCache = true;
  }

  /// Reads user-added foods. Returns `[]` when the file is missing.
  /// Throws [CacheException] if the file is corrupt.
  Future<List<FoodModel>> readCustomFoods() async {
    final data = await JsonFileStorage.readJson(customFoodsFilename);
    if (data == null) return [];
    return _parseList(data);
  }

  /// Replaces the full custom-foods file (read-modify-write from repository).
  Future<void> writeCustomFoods(List<FoodModel> foods) async {
    await JsonFileStorage.writeJson(
      customFoodsFilename,
      foods.map((f) => f.toJson()).toList(),
    );
  }

  List<FoodModel> _parseList(dynamic data) {
    if (data is! List) {
      throw const CacheException('Catalog file is not a JSON list');
    }
    try {
      return data
          .map((e) => FoodModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException('Catalog file is corrupt: $e');
    }
  }
}