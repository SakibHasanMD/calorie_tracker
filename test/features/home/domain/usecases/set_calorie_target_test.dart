import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/home/domain/usecases/set_calorie_target.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockCalorieTargetRepository repository;
  late SetCalorieTarget usecase;

  setUp(() {
    repository = MockCalorieTargetRepository();
    usecase = SetCalorieTarget(repository: repository);
  });

  test('sets the target via the repository', () async {
    when(() => repository.setTarget(1800))
        .thenAnswer((_) async => const Right(unit));
    final result = await usecase(1800);
    expect(result.isRight(), isTrue);
    verify(() => repository.setTarget(1800)).called(1);
  });

  test('propagates a repository failure', () async {
    when(() => repository.setTarget(-1)).thenAnswer(
      (_) async => const Left(
        ValidationFailure(message: 'Target must be greater than zero.'),
      ),
    );
    final result = await usecase(-1);
    expect(result.isLeft(), isTrue);
  });
}
