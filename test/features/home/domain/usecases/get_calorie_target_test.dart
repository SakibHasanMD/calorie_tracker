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

  test('returns the target for the requested date', () async {
    when(() => repository.getTarget('2024-09-26'))
        .thenAnswer((_) async => const Right(1800));
    final result = await usecase('2024-09-26');
    expect(result.isRight(), isTrue);
    expect(result.getRight().toNullable(), 1800);
    verify(() => repository.getTarget('2024-09-26')).called(1);
  });

  test('propagates a repository failure', () async {
    when(() => repository.getTarget('2024-09-26')).thenAnswer(
      (_) async => const Left(
        CacheFailure(message: 'Could not read your calorie target.'),
      ),
    );
    final result = await usecase('2024-09-26');
    expect(result.isLeft(), isTrue);
  });
}