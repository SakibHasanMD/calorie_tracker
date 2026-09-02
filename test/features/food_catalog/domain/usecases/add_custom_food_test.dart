import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/food_catalog/domain/usecases/add_custom_food.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/fixtures.dart';
import '../../../../test_helpers/mocks.dart';

void main() {
  late MockFoodCatalogRepository repository;
  late AddCustomFood usecase;

  setUp(() {
    repository = MockFoodCatalogRepository();
    usecase = AddCustomFood(repository: repository);
  });

  test('calls repository.addCustomFood and passes through the saved food',
      () async {
    when(() => repository.addCustomFood(sampleCustomFood))
        .thenAnswer((_) async => const Right(sampleCustomFood));

    final result = await usecase.call(sampleCustomFood);

    expect(result.getRight().toNullable(), sampleCustomFood);
    verify(() => repository.addCustomFood(sampleCustomFood)).called(1);
  });

  test('passes through a failure', () async {
    const failure = ValidationFailure(message: 'bad');
    when(() => repository.addCustomFood(sampleCustomFood))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call(sampleCustomFood);

    expect(result.getLeft().toNullable(), failure);
    verify(() => repository.addCustomFood(sampleCustomFood)).called(1);
  });
}
