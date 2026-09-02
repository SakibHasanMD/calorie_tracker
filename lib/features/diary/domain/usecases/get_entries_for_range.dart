import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Entries in the inclusive range `[startDate, endDate]` (`YYYY-MM-DD`).
///
/// History and Statistics features use this through their own usecases; they
/// never call the repository directly.
class GetEntriesForRange {
  const GetEntriesForRange({required DiaryRepository repository})
      : _repository = repository;

  final DiaryRepository _repository;

  Future<Either<Failure, List<DiaryEntry>>> call(
    String startDate,
    String endDate,
  ) =>
      _repository.getEntriesForRange(startDate, endDate);
}
