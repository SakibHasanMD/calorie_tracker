import 'package:bloc_test/bloc_test.dart';
import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:calorie_tracker/features/food_catalog/presentation/cubit/food_catalog_cubit.dart';
import 'package:calorie_tracker/features/food_catalog/presentation/cubit/food_catalog_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/fixtures.dart';
import '../../../../test_helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(sampleSeedGramFood);
  });

  late MockGetAllFoods getAllFoods;
  late MockAddCustomFood addCustomFood;
  late MockUpdateCustomFood updateCustomFood;
  late MockDeleteCustomFood deleteCustomFood;

  setUp(() {
    getAllFoods = MockGetAllFoods();
    addCustomFood = MockAddCustomFood();
    updateCustomFood = MockUpdateCustomFood();
    deleteCustomFood = MockDeleteCustomFood();
  });

  FoodCatalogCubit build() => FoodCatalogCubit(
        getAllFoods: getAllFoods,
        addCustomFood: addCustomFood,
        updateCustomFood: updateCustomFood,
        deleteCustomFood: deleteCustomFood,
      );

  group('loadFoods', () {
    blocTest<FoodCatalogCubit, FoodCatalogState>(
      'emits loading then loaded on success',
      build: () {
        when(() => getAllFoods()).thenAnswer(
          (_) async => const Right<Failure, List<Food>>([
            sampleSeedGramFood,
            sampleCustomFood,
          ]),
        );
        return build();
      },
      act: (cubit) => cubit.loadFoods(),
      expect: () => [
        const FoodCatalogState(status: FoodCatalogStatus.loading),
        const FoodCatalogState(
          status: FoodCatalogStatus.loaded,
          foods: [sampleSeedGramFood, sampleCustomFood],
        ),
      ],
    );

    blocTest<FoodCatalogCubit, FoodCatalogState>(
      'emits loading then error on failure',
      build: () {
        when(() => getAllFoods()).thenAnswer(
          (_) async => const Left<Failure, List<Food>>(
            CacheFailure(message: 'boom'),
          ),
        );
        return build();
      },
      act: (cubit) => cubit.loadFoods(),
      expect: () => [
        const FoodCatalogState(status: FoodCatalogStatus.loading),
        const FoodCatalogState(
          status: FoodCatalogStatus.error,
          failure: CacheFailure(message: 'boom'),
        ),
      ],
    );
  });

  group('search', () {
    blocTest<FoodCatalogCubit, FoodCatalogState>(
      'updates the active query against the loaded list',
      build: () {
        when(() => getAllFoods()).thenAnswer(
          (_) async => const Right<Failure, List<Food>>([
            sampleSeedGramFood,
            sampleSeedPieceFood,
            sampleCustomFood,
          ]),
        );
        return build();
      },
      act: (cubit) async {
        await cubit.loadFoods();
        cubit.search('rice');
      },
      skip: 2, // skip loading + loaded emissions from loadFoods
      expect: () => [
        const FoodCatalogState(
          status: FoodCatalogStatus.loaded,
          foods: [sampleSeedGramFood, sampleSeedPieceFood, sampleCustomFood],
          query: 'rice',
        ),
      ],
    );

    blocTest<FoodCatalogCubit, FoodCatalogState>(
      'is a no-op when the catalog is not yet loaded',
      build: () => build(),
      act: (cubit) => cubit.search('rice'),
      expect: () => const <FoodCatalogState>[],
    );
  });

  group('addCustom', () {
    blocTest<FoodCatalogCubit, FoodCatalogState>(
      'appends the added food and stays in loaded',
      build: () {
        when(() => getAllFoods()).thenAnswer(
          (_) async => const Right<Failure, List<Food>>([sampleSeedGramFood]),
        );
        when(() => addCustomFood(any())).thenAnswer(
          (_) async => const Right<Failure, Food>(sampleCustomFood),
        );
        return build();
      },
      act: (cubit) async {
        await cubit.loadFoods();
        await cubit.addCustom(sampleCustomFood);
      },
      skip: 2, // skip loading + loaded emissions from loadFoods
      expect: () => [
        const FoodCatalogState(
          status: FoodCatalogStatus.loaded,
          foods: [sampleSeedGramFood, sampleCustomFood],
        ),
      ],
    );

    blocTest<FoodCatalogCubit, FoodCatalogState>(
      'emits error on add failure',
      build: () {
        when(() => getAllFoods()).thenAnswer(
          (_) async => const Right<Failure, List<Food>>([sampleSeedGramFood]),
        );
        when(() => addCustomFood(any())).thenAnswer(
          (_) async => const Left<Failure, Food>(
            ValidationFailure(message: 'bad'),
          ),
        );
        return build();
      },
      act: (cubit) async {
        await cubit.loadFoods();
        await cubit.addCustom(sampleCustomFood);
      },
      skip: 2,
      expect: () => [
        const FoodCatalogState(
          status: FoodCatalogStatus.error,
          foods: [sampleSeedGramFood],
          failure: ValidationFailure(message: 'bad'),
        ),
      ],
    );
  });

  group('updateCustom', () {
    blocTest<FoodCatalogCubit, FoodCatalogState>(
      'replaces the matching food in place',
      build: () {
        when(() => getAllFoods()).thenAnswer(
          (_) async => const Right<Failure, List<Food>>([
            sampleSeedGramFood,
            sampleCustomFood,
          ]),
        );
        final updated = sampleCustomFood.copyWith(name: 'Updated shake');
        when(() => updateCustomFood(any())).thenAnswer(
          (_) async => Right<Failure, Food>(updated),
        );
        return build();
      },
      act: (cubit) async {
        await cubit.loadFoods();
        await cubit
            .updateCustom(sampleCustomFood.copyWith(name: 'Updated shake'));
      },
      skip: 2,
      expect: () => [
        FoodCatalogState(
          status: FoodCatalogStatus.loaded,
          foods: [
            sampleSeedGramFood,
            sampleCustomFood.copyWith(name: 'Updated shake'),
          ],
        ),
      ],
    );
  });

  group('deleteCustom', () {
    blocTest<FoodCatalogCubit, FoodCatalogState>(
      'removes the matching food from the list',
      build: () {
        when(() => getAllFoods()).thenAnswer(
          (_) async => const Right<Failure, List<Food>>([
            sampleSeedGramFood,
            sampleCustomFood,
          ]),
        );
        when(() => deleteCustomFood(any())).thenAnswer(
          (_) async => const Right<Failure, Unit>(unit),
        );
        return build();
      },
      act: (cubit) async {
        await cubit.loadFoods();
        await cubit.deleteCustom(sampleCustomFood.id);
      },
      skip: 2,
      expect: () => [
        const FoodCatalogState(
          status: FoodCatalogStatus.loaded,
          foods: [sampleSeedGramFood],
        ),
      ],
    );

    blocTest<FoodCatalogCubit, FoodCatalogState>(
      'emits error on delete failure',
      build: () {
        when(() => getAllFoods()).thenAnswer(
          (_) async => const Right<Failure, List<Food>>([sampleSeedGramFood]),
        );
        when(() => deleteCustomFood(any())).thenAnswer(
          (_) async => const Left<Failure, Unit>(
            NotFoundFailure(message: 'gone'),
          ),
        );
        return build();
      },
      act: (cubit) async {
        await cubit.loadFoods();
        await cubit.deleteCustom('missing');
      },
      skip: 2,
      expect: () => [
        const FoodCatalogState(
          status: FoodCatalogStatus.error,
          foods: [sampleSeedGramFood],
          failure: NotFoundFailure(message: 'gone'),
        ),
      ],
    );
  });
}
