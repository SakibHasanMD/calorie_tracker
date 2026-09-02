import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/food_catalog/domain/usecases/get_all_foods.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/fixtures.dart';
import '../../../../test_helpers/mocks.dart';

void main() {
  late MockFoodCatalogRepository repository;
  late GetAllFoods usecase;

  setUp(() {
    repository = MockFoodCatalogRepository();
    usecase = GetAllFoods(repository: repository);
  });

  test('calls repository.getAllFoods and passes the result through', () async {
    when(() => repository.getAllFoods()).thenAnswer(
        (_) async => const Right([sampleSeedGramFood, sampleCustomFood]));

    final result = await usecase();

    expect(result.isRight(), isTrue);
    expect(
        result.getRight().toNullable(), [sampleSeedGramFood, sampleCustomFood]);
    verify(() => repository.getAllFoods()).called(1);
  });

  test('passes through a failure', () async {
    const failure = CacheFailure(message: 'nope');
    when(() => repository.getAllFoods())
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase();

    expect(result.isLeft(), isTrue);
    expect(result.getLeft().toNullable(), failure);
    verify(() => repository.getAllFoods()).called(1);
  });
}
