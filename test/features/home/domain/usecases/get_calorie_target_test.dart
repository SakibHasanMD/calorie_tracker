import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/home/domain/usecases/get_calorie_target.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockCalorieTargetRepository repository;
  late GetCalorieTarget usecase;

  setUp(() {
    repository = MockCalorieTargetRepository();
    usecase = GetCalorieTarget(repository: repository);
  });

  test('returns the target from the repository', () async {
    when(() => repository.getTarget()).thenAnswer((_) async => const Right(2000));
    final result = await usecase();
    expect(result.isRight(), isTrue);
    expect(result.getRight().toNullable(), 2000);
    verify(() => repository.getTarget()).called(1);
  });

  test('propagates a repository failure', () async {
    when(() => repository.getTarget()).thenAnswer(
      (_) async => const Left(
        CacheFailure(message: 'Could not read your calorie target.'),
      ),
    );
    final result = await usecase();
    expect(result.isLeft(), isTrue);
  });
}
