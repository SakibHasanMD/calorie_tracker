import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/get_entries_for_range.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockDiaryRepository repository;
  late GetEntriesForRange usecase;

  setUp(() {
    repository = MockDiaryRepository();
    usecase = GetEntriesForRange(repository: repository);
  });

  test('calls repository.getEntriesForRange with the given dates', () async {
    when(() => repository.getEntriesForRange('2024-09-01', '2024-09-30'))
        .thenAnswer((_) async => const Right([]));

    final result = await usecase.call('2024-09-01', '2024-09-30');

    expect(result.isRight(), isTrue);
    verify(() => repository.getEntriesForRange('2024-09-01', '2024-09-30')).called(1);
  });

  test('passes through a failure', () async {
    const failure = CacheFailure(message: 'db read fail');
    when(() => repository.getEntriesForRange('2024-01-01', '2024-12-31'))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call('2024-01-01', '2024-12-31');

    expect(result.getLeft().toNullable(), failure);
  });
}
