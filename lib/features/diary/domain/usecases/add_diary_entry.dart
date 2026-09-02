import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Adds a new diary entry.
class AddDiaryEntry {
  const AddDiaryEntry({required DiaryRepository repository}) : _repository = repository;

  final DiaryRepository _repository;

  Future<Either<Failure, DiaryEntry>> call(DiaryEntry entry) =>
      _repository.addEntry(entry);
}
