import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/delete_diary_entry.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockDiaryRepository repository;
  late DeleteDiaryEntry usecase;

  setUp(() {
    repository = MockDiaryRepository();
    usecase = DeleteDiaryEntry(repository: repository);
  });

  test('calls repository.deleteEntry with the id', () async {
    when(() => repository.deleteEntry(42))
        .thenAnswer((_) async => const Right(unit));

    final result = await usecase.call(42);

    expect(result.isRight(), isTrue);
    verify(() => repository.deleteEntry(42)).called(1);
  });

  test('passes through a failure', () async {
    const failure = CacheFailure(message: 'write fail');
    when(() => repository.deleteEntry(1))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call(1);

    expect(result.getLeft().toNullable(), failure);
  });
}
