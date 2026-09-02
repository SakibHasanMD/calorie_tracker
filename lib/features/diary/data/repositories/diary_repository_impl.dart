import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/repositories/diary_repository.dart';
import '../datasources/diary_local_datasource.dart';
import '../models/diary_entry_model.dart';

/// Concrete [DiaryRepository] backed by sqflite. The only place where
/// `try/catch` around the datasource becomes a [Failure].
class DiaryRepositoryImpl implements DiaryRepository {
  DiaryRepositoryImpl({required DiaryLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  final DiaryLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, DiaryEntry>> addEntry(DiaryEntry entry) async {
    try {
      final model = DiaryEntryModel.fromEntity(entry);
      final id = await _localDataSource.insert(model);
      return Right(model.copyWith(id: id));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Failed to add entry'));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to add entry: $e'));
    }
  }

  @override
  Future<Either<Failure, DiaryEntry>> updateEntry(DiaryEntry entry) async {
    try {
      final id = entry.id;
      if (id == null) {
        return const Left(NotFoundFailure(message: 'Entry has no id'));
      }
      final model = DiaryEntryModel.fromEntity(entry);
      final affected = await _localDataSource.update(model);
      if (affected == 0) {
        return Left(NotFoundFailure(message: 'Entry $id not found'));
      }
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Failed to update entry'));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to update entry: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteEntry(int id) async {
    try {
      await _localDataSource.delete(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Failed to delete entry'));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to delete entry: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getEntriesForDate(
    String date,
  ) async {
    try {
      final rows = await _localDataSource.findByDate(date);
      return Right(rows.cast<DiaryEntry>());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Failed to load entries'));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to load entries: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getEntriesForRange(
    String startDate,
    String endDate,
  ) async {
    try {
      final rows = await _localDataSource.findByRange(startDate, endDate);
      return Right(rows.cast<DiaryEntry>());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message ?? 'Failed to load entries'));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to load entries: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DiaryEntry>>> getRecentFoods(int limit) async {
    try {
      final rows = await _localDataSource.findRecentDistinctFoods(limit);
      return Right(rows.cast<DiaryEntry>());
    } on CacheException catch (e) {
      return Left(
        CacheFailure(message: e.message ?? 'Failed to load recent foods'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to load recent foods: $e'));
    }
  }
}
