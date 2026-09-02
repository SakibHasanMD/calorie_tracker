import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/food_catalog/domain/usecases/delete_custom_food.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockFoodCatalogRepository repository;
  late DeleteCustomFood usecase;

  setUp(() {
    repository = MockFoodCatalogRepository();
    usecase = DeleteCustomFood(repository: repository);
  });

  test('calls repository.deleteCustomFood with the id', () async {
    when(() => repository.deleteCustomFood('custom_abc'))
        .thenAnswer((_) async => const Right(unit));

    final result = await usecase.call('custom_abc');

    expect(result.isRight(), isTrue);
    verify(() => repository.deleteCustomFood('custom_abc')).called(1);
  });

  test('passes through a failure', () async {
    const failure = NotFoundFailure();
    when(() => repository.deleteCustomFood('custom_abc'))
        // ignore: prefer_const_constructors
        .thenAnswer((_) async => Left(failure));

    final result = await usecase.call('custom_abc');

    expect(result.getLeft().toNullable(), failure);
  });
}
