import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's daily calorie target to SharedPreferences.
///
/// Mirrors the other local data sources (e.g. the food catalog's JSON file
/// store) but for a single lightweight numeric preference.
class CalorieTargetLocalDataSource {
  CalorieTargetLocalDataSource();

  /// The preferences key that stores the daily calorie target (int).
  static const String _key = 'daily_calorie_target';

  /// Default target used before the user has explicitly set one.
  static const int defaultTarget = 2000;

  Future<int> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? defaultTarget;
  }

  Future<void> write(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, value);
  }
}
