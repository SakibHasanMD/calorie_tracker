import 'package:path_provider/path_provider.dart';

/// Single source of truth for resolving the persistent application documents
/// directory. No other file should hardcode filesystem paths.
abstract final class AppPaths {
  static String? _documentsPath;

  /// Resolves (and caches) the app's persistent documents directory.
  ///
  /// On Android/iOS this is the app's documents directory. On desktop it is a
  /// platform-appropriate persistent location. Returns null before plugins
  /// are available (only relevant in exotic test setups).
  static Future<String> documentsDirectory() async {
    if (_documentsPath != null) return _documentsPath!;
    final dir = await getApplicationDocumentsDirectory();
    _documentsPath = dir.path;
    return _documentsPath!;
  }

  /// Resolves the full path for [filename] inside the documents directory.
  static Future<String> filePath(String filename) async {
    final base = await documentsDirectory();
    return '$base/$filename';
  }

  /// Allows tests (or callers) to pre-set the resolved directory so real
  /// plugins are not required. Resets the internal cache.
  static void overrideForTesting(String path) {
    _documentsPath = path;
  }
}