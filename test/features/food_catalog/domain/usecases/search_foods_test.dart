import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/food_catalog/domain/usecases/search_foods.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/fixtures.dart';
import '../../../../test_helpers/mocks.dart';

void main() {
  late MockFoodCatalogRepository repository;
  late SearchFoods usecase;

  setUp(() {
    repository = MockFoodCatalogRepository();
    usecase = SearchFoods(repository: repository);
  });

  test('calls repository.searchFoods with the query and passes through', () async {
    when(() => repository.searchFoods('rice')).thenAnswer(
      (_) async => Right([sampleSeedGramFood]),
    );

    final result = await usecase.call('rice');

    expect(result.isRight(), isTrue);
    expect(result.getRight().toNullable(), [sampleSeedGramFood]);
    verify(() => repository.searchFoods('rice')).called(1);
  });

  test('passes through a failure', () async {
    const failure = UnexpectedFailure();
    when(() => repository.searchFoods('x'))
        .thenAnswer((_) async => Left(failure));

    final result = await usecase.call('x');

    expect(result.getLeft().toNullable(), failure);
    verify(() => repository.searchFoods('x')).called(1);
  });
}