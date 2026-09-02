import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';

/// Abstract interface for diary persistence.
abstract interface class DiaryRepository {
  /// Inserts the entry and returns it with the assigned id.
  Future<Either<Failure, DiaryEntry>> addEntry(DiaryEntry entry);

  /// Updates the entry in place. Fails with [NotFoundFailure] if no row
  /// matches [DiaryEntry.id].
  Future<Either<Failure, DiaryEntry>> updateEntry(DiaryEntry entry);

  /// Deletes the entry with [id]. No-op if not present (succeeds either way).
  Future<Either<Failure, Unit>> deleteEntry(int id);

  /// Entries whose [DiaryEntry.entryDate] equals [date] (`YYYY-MM-DD`),
  /// oldest first.
  Future<Either<Failure, List<DiaryEntry>>> getEntriesForDate(String date);

  /// Entries whose [DiaryEntry.entryDate] is in the inclusive range
  /// `[startDate, endDate]` (`YYYY-MM-DD`), oldest first.
  Future<Either<Failure, List<DiaryEntry>>> getEntriesForRange(
    String startDate,
    String endDate,
  );

  /// Most-recently-used distinct foods (by [DiaryEntry.foodId]) capped at
  /// [limit], ordered by the most recent [DiaryEntry.createdAt] first.
  Future<Either<Failure, List<DiaryEntry>>> getRecentFoods(int limit);
}
