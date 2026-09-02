import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Owns the single shared sqflite [Database] instance and its schema version.
///
/// It intentionally does NOT own any table DDL — table creation/query DDL
/// lives in each feature's `data` layer (e.g. `diary_local_datasource` for the
/// `diary_entries` table in Track 3). This file only knows how to open and
/// return the shared database.
///
/// Why no `onCreate` here: features create their own tables on first use.
/// Bump [version] whenever the schema across any feature changes so future
/// migrations can run.
///
/// Tests should set `databaseFactory = databaseFactoryFfi` (from
/// `sqflite_common_ffi`) before first use so [openDatabase] below routes
/// through the FFI factory. See `test/core/database/app_database_test.dart`.
abstract final class AppDatabase {
  /// Database file name / user-visible identifier.
  static const String databaseName = 'calorie_tracker.db';

  /// Current schema version for the shared database.
  static const int version = 1;

  static Database? _database;

  /// Returns the shared database, opening it on first use.
  static Future<Database> instance() async {
    final existing = _database;
    if (existing != null) return existing;
    final db = await _open();
    _database = db;
    return db;
  }

  static Future<Database> _open() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, databaseName);
    return openDatabase(
      path,
      version: version,
      // Tables are created by their owning feature's data layer, not here.
    );
  }

  /// Opens a fresh, isolated in-memory database — useful for tests.
  ///
  /// The caller owns the returned handle (it is not cached as the singleton)
  /// and should close it after use.
  static Future<Database> openInMemory() async {
    return openDatabase(
      inMemoryDatabasePath,
      version: version,
    );
  }

  /// Replaces the cached singleton instance. Primarily for tests that open a
  /// database via [openInMemory] and want it to be the shared instance.
  static void overrideInstance(Database? db) {
    _database = db;
  }

  /// Closes and clears the cached instance (used in teardown).
  static Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null) await db.close();
  }
}