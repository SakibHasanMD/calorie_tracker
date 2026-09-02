import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Updates an existing diary entry.
class UpdateDiaryEntry {
  const UpdateDiaryEntry({required DiaryRepository repository}) : _repository = repository;

  final DiaryRepository _repository;

  Future<Either<Failure, DiaryEntry>> call(DiaryEntry entry) =>
      _repository.updateEntry(entry);
}
