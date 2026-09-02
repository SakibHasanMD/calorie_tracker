import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/get_entries_for_date.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockDiaryRepository repository;
  late GetEntriesForDate usecase;

  setUp(() {
    repository = MockDiaryRepository();
    usecase = GetEntriesForDate(repository: repository);
  });

  test('calls repository.getEntriesForDate and passes through', () async {
    when(() => repository.getEntriesForDate('2024-09-01'))
        .thenAnswer((_) async => const Right([]));

    final result = await usecase.call('2024-09-01');

    expect(result.isRight(), isTrue);
    expect(result.getRight().toNullable(), isEmpty);
    verify(() => repository.getEntriesForDate('2024-09-01')).called(1);
  });

  test('passes through a failure', () async {
    const failure = CacheFailure(message: 'db error');
    when(() => repository.getEntriesForDate('2024-09-01'))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call('2024-09-01');

    expect(result.getLeft().toNullable(), failure);
  });
}
