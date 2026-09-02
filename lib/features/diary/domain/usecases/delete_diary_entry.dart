import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../repositories/diary_repository.dart';

/// Deletes a diary entry by id.
class DeleteDiaryEntry {
  const DeleteDiaryEntry({required DiaryRepository repository}) : _repository = repository;

  final DiaryRepository _repository;

  Future<Either<Failure, Unit>> call(int id) => _repository.deleteEntry(id);
}
