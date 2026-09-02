import 'package:sqflite/sqflite.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/error/exceptions.dart';
import '../models/diary_entry_model.dart';

/// Owns the `diary_entries` table DDL and raw sqflite queries for the diary
/// feature. Reads/writes go against the shared [AppDatabase] singleton.
class DiaryLocalDataSource {
  DiaryLocalDataSource({Future<Database> Function()? databaseProvider})
      : _databaseProvider =
            databaseProvider ?? AppDatabase.instance;

  final Future<Database> Function() _databaseProvider;

  /// Create the table if it doesn't exist. Safe to call multiple times.
  Future<void> ensureTable() async {
    final db = await _databaseProvider();
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS diary_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          foodId TEXT NOT NULL,
          foodName TEXT NOT NULL,
          measurementType TEXT NOT NULL,
          amount REAL NOT NULL,
          calories REAL NOT NULL,
          entryDate TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_diary_entries_date ON diary_entries(entryDate)',
      );
    } catch (e) {
      throw CacheException('Failed to create diary_entries table: $e');
    }
  }

  Future<int> insert(DiaryEntryModel model) async {
    final db = await _databaseProvider();
    try {
      return await db.insert('diary_entries', model.toMap());
    } catch (e) {
      throw CacheException('Failed to insert diary entry: $e');
    }
  }

  Future<int> update(DiaryEntryModel model) async {
    final db = await _databaseProvider();
    try {
      final id = model.id;
      if (id == null) {
        throw const CacheException('Cannot update entry without id');
      }
      return await db.update(
        'diary_entries',
        model.toMap(),
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException('Failed to update diary entry: $e');
    }
  }

  Future<int> delete(int id) async {
    final db = await _databaseProvider();
    try {
      return await db.delete(
        'diary_entries',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw CacheException('Failed to delete diary entry: $e');
    }
  }

  Future<List<DiaryEntryModel>> findByDate(String date) async {
    final db = await _databaseProvider();
    try {
      final rows = await db.query(
        'diary_entries',
        where: 'entryDate = ?',
        whereArgs: [date],
        orderBy: 'createdAt ASC',
      );
      return rows.map(DiaryEntryModel.fromMap).toList();
    } catch (e) {
      throw CacheException('Failed to load diary entries: $e');
    }
  }

  Future<List<DiaryEntryModel>> findByRange(
    String startDate,
    String endDate,
  ) async {
    final db = await _databaseProvider();
    try {
      final rows = await db.query(
        'diary_entries',
        where: 'entryDate BETWEEN ? AND ?',
        whereArgs: [startDate, endDate],
        orderBy: 'createdAt ASC',
      );
      return rows.map(DiaryEntryModel.fromMap).toList();
    } catch (e) {
      throw CacheException('Failed to load diary entries: $e');
    }
  }

  /// Returns the most-recently-logged entry per distinct `foodId`, capped at
  /// [limit]. Orders by the most recent `createdAt` first.
  Future<List<DiaryEntryModel>> findRecentDistinctFoods(int limit) async {
    final db = await _databaseProvider();
    try {
      // SQLite allows referencing the outer table in correlated subqueries.
      // We pick the most recent row per foodId via a self-join, then order.
      final rows = await db.rawQuery('''
        SELECT d.* FROM diary_entries d
        WHERE d.id = (
          SELECT d2.id FROM diary_entries d2
          WHERE d2.foodId = d.foodId
          ORDER BY d2.createdAt DESC
          LIMIT 1
        )
        ORDER BY d.createdAt DESC
        LIMIT ?
      ''', [limit]);
      return rows.map(DiaryEntryModel.fromMap).toList();
    } catch (e) {
      throw CacheException('Failed to load recent foods: $e');
    }
  }
}
