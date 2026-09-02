import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'app_paths.dart';

/// Generic JSON file read/write helper backed by the app's documents dir.
///
/// Used by the food_catalog feature (Track 2) to persist `food_catalog.json`
/// and `custom_foods.json`. Kept in `core` so it is reusable and so the path
/// resolution lives in [AppPaths] rather than being duplicated.
abstract final class JsonFileStorage {
  /// Returns `true` if [filename] already exists in the documents directory.
  static Future<bool> exists(String filename) async {
    final path = await AppPaths.filePath(filename);
    return File(path).exists();
  }

  /// Reads [filename] and decodes it. Returns `null` if the file is missing.
  ///
  /// Throws a [FormatException] (JSON parse) or [IOException] if the file is
  /// corrupt — callers decide whether to surface a [Failure] or fall back.
  static Future<dynamic> readJson(String filename) async {
    final path = await AppPaths.filePath(filename);
    final file = File(path);
    if (!await file.exists()) return null;
    final contents = await file.readAsString();
    return jsonDecode(contents);
  }

  /// Writes [data] (any JSON-encodable value) to [filename], creating the file.
  static Future<void> writeJson(String filename, dynamic data) async {
    final path = await AppPaths.filePath(filename);
    await Directory(p.dirname(path)).create(recursive: true);
    final file = File(path);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(data));
  }
}