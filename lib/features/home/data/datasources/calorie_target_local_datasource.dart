import 'dart:convert';

import '../../../../core/storage/json_file_storage.dart';

/// Persists date-scoped daily calorie targets as a JSON map of
/// `YYYY-MM-DD → target` in the app's documents directory.
///
/// A map (rather than per-period records) keeps lookups deterministic: the
/// effective target for any date is simply the value stored under that date,
/// or [defaultTarget] when absent. Setting a target for a week/month/year
/// writes the same value to every day in that range (computed by the
/// repository).
class CalorieTargetLocalDataSource {
  CalorieTargetLocalDataSource();

  static const String _fileName = 'calorie_targets.json';

  /// Default target used before the user has explicitly set one for a date.
  /// (May move to onboarding in a later version.)
  static const int defaultTarget = 2000;

  /// All stored targets, keyed by `YYYY-MM-DD`. Missing file → empty map.
  Future<Map<String, int>> readAll() async {
    final raw = await JsonFileStorage.readJson(_fileName);
    if (raw == null) return {};
    final decoded = jsonDecode(jsonEncode(raw));
    if (decoded is! Map) return {};
    return decoded.map(
      (key, value) => MapEntry(key.toString(), (value as num).toInt()),
    );
  }

  /// Replaces the whole targets map. Creating the file as needed.
  Future<void> writeAll(Map<String, int> targets) async {
    await JsonFileStorage.writeJson(_fileName, targets);
  }
}