import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/get_recent_foods.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockDiaryRepository repository;
  late GetRecentFoods usecase;

  setUp(() {
    repository = MockDiaryRepository();
    usecase = GetRecentFoods(repository: repository);
  });

  test('calls repository.getRecentFoods with the given limit', () async {
    when(() => repository.getRecentFoods(8))
        .thenAnswer((_) async => const Right([]));

    final result = await usecase.call(limit: 8);

    expect(result.isRight(), isTrue);
    verify(() => repository.getRecentFoods(8)).called(1);
  });

  test('passes through a failure', () async {
    const failure = CacheFailure(message: 'read fail');
    when(() => repository.getRecentFoods(any()))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call();

    expect(result.isLeft(), isTrue);
    expect(result.getLeft().toNullable(), failure);
  });
}
