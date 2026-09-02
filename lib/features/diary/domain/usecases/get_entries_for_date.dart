import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Entries for a single calendar day (`YYYY-MM-DD`).
class GetEntriesForDate {
  const GetEntriesForDate({required DiaryRepository repository})
      : _repository = repository;

  final DiaryRepository _repository;

  Future<Either<Failure, List<DiaryEntry>>> call(String date) =>
      _repository.getEntriesForDate(date);
}
