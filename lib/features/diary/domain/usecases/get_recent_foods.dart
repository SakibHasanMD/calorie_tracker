import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/diary_entry.dart';
import '../repositories/diary_repository.dart';

/// Most-recently-used distinct foods (by `foodId`) capped at [limit].
///
/// One entry per distinct food; `createdAt` of the most recent log for that
/// food is preserved on the returned entry. Drives the "recent foods" row on
/// the entry form.
class GetRecentFoods {
  const GetRecentFoods({required DiaryRepository repository}) : _repository = repository;

  final DiaryRepository _repository;

  Future<Either<Failure, List<DiaryEntry>>> call({int limit = 5}) =>
      _repository.getRecentFoods(limit);
}
