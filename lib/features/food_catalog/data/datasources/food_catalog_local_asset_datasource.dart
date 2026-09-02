import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/food_model.dart';

/// Bundled seed catalog used as the stand-in for the future Azure fetch.
///
/// This datasource exposes the same `fetchFoods()` signature that a future
/// `FoodCatalogHttpDataSource` will implement, so replacing the source of the
/// catalog requires zero changes above this data layer.
class FoodCatalogLocalAssetDataSource {
  /// Asset path where the seed catalog is bundled (see pubspec assets).
  static const String assetPath = 'assets/data/foods_seed.json';

  /// Loads the bundled seed JSON and parses it to a list of [FoodModel].
  Future<List<FoodModel>> fetchFoods() async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => FoodModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}