import 'package:calorie_tracker/core/error/exceptions.dart';
import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/food_catalog/data/models/food_model.dart';
import 'package:calorie_tracker/features/food_catalog/data/repositories/food_catalog_repository_impl.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockFoodCatalogLocalAssetDataSource asset;
  late MockFoodCatalogPersistedDataSource persisted;
  late FoodCatalogRepositoryImpl repo;

  final seedFood = FoodModel(
    id: 'seed_0001',
    name: 'Rice',
    category: 'Grains',
    measurementType: MeasurementType.gram,
    caloriesPerGram: 1.3,
    caloriesPerPiece: null,
  );

  setUp(() {
    asset = MockFoodCatalogLocalAssetDataSource();
    persisted = MockFoodCatalogPersistedDataSource();
    repo = FoodCatalogRepositoryImpl(
      localAssetDataSource: asset,
      persistedDataSource: persisted,
    );
    // Default datasource behaviours.
    when(() => persisted.catalogFileExists()).thenAnswer((_) async => false);
    when(() => persisted.readCatalog()).thenAnswer((_) async => <FoodModel>[]);
    when(() => persisted.readCustomFoods())
        .thenAnswer((_) async => <FoodModel>[]);
    when(() => asset.fetchFoods()).thenAnswer((_) async => [seedFood]);
    when(() => persisted.writeCatalog(any()))
        .thenAnswer((_) async {});
    when(() => persisted.writeCustomFoods(any()))
        .thenAnswer((_) async {});
  });

  group('getAllFoods', () {
    test('seeds the catalog from the asset on first launch, then returns it',
        () async {
      final result = await repo.getAllFoods();

      expect(result.isRight(), isTrue);
      expect(result.getRight().toNullable()!.map((f) => f.id),
          containsAll([seedFood.id]));
      verify(() => asset.fetchFoods()).called(1);
      verify(() => persisted.writeCatalog([seedFood])).called(1);
      // Asset source is only read on first launch.
      verifyNever(() => persisted.readCatalog());
    });

    test('subsequent launches read only the persisted file, never the asset',
        () async {
      when(() => persisted.catalogFileExists()).thenAnswer((_) async => true);
      when(() => persisted.readCatalog())
          .thenAnswer((_) async => [seedFood]);

      final result = await repo.getAllFoods();

      expect(result.isRight(), isTrue);
      expect(result.getRight().toNullable()!.single.id, seedFood.id);
      verifyNever(() => asset.fetchFoods());
      verify(() => persisted.readCatalog()).called(1);
    });

    test('merges custom foods into the combined list', () async {
      when(() => persisted.catalogFileExists()).thenAnswer((_) async => true);
      when(() => persisted.readCatalog())
          .thenAnswer((_) async => [seedFood]);
      final custom = FoodModel(
        id: 'custom_1',
        name: 'Protein shake',
        category: 'Protein',
        measurementType: MeasurementType.gram,
        caloriesPerGram: 0.9,
        caloriesPerPiece: null,
        isCustom: true,
        createdAt: '2024-01-01T00:00:00.000',
      );
      when(() => persisted.readCustomFoods())
          .thenAnswer((_) async => [custom]);

      final result = await repo.getAllFoods();

      final foods = result.getRight().toNullable()!;
      expect(foods.map((f) => f.id), containsAll(['seed_0001', 'custom_1']));
    });

    test('maps a corrupt persisted catalog to a CacheFailure', () async {
      when(() => persisted.catalogFileExists()).thenAnswer((_) async => true);
      when(() => persisted.readCatalog())
          .thenThrow(const CacheException('corrupt'));

      final result = await repo.getAllFoods();

      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<CacheFailure>());
      verifyNever(() => asset.fetchFoods());
    });

    test('maps a missing asset on first launch to a failure', () async {
      when(() => asset.fetchFoods()).thenThrow(Exception('asset gone'));

      final result = await repo.getAllFoods();

      expect(result.isLeft(), isTrue);
      expect(result.getLeft().toNullable(), isA<UnexpectedFailure>());
    });
  });

  group('searchFoods', () {
    test('filters the combined catalog', () async {
      when(() => persisted.catalogFileExists()).thenAnswer((_) async => true);
      when(() => persisted.readCatalog()).thenAnswer((_) async => [
            seedFood,
            FoodModel(
              id: 'seed_0002',
              name: 'Chicken breast',
              category: 'Protein',
              measurementType: MeasurementType.gram,
              caloriesPerGram: 1.65,
              caloriesPerPiece: null,
            ),
          ]);

      final result = await repo.searchFoods('rice');

      expect(result.isRight(), isTrue);
      expect(result.getRight().toNullable()!.single.name, 'Rice');
    });
  });

  group('addCustomFood', () {
    test('appends a custom food and persists to custom_foods.json', () async {
      FoodModel? written;
      when(() => persisted.writeCustomFoods(any())).thenAnswer((invocation) async {
        written = (invocation.positionalArguments.single as List<FoodModel>)
            .single;
      });

      final result = await repo.addCustomFood(
        Food(
          id: '',
          name: '  Protein shake  ',
          category: 'Protein',
          measurementType: MeasurementType.gram,
          caloriesPerGram: 0.9,
          caloriesPerPiece: null,
        ),
      );

      expect(result.isRight(), isTrue);
      final added = result.getRight().toNullable()!;
      expect(added.id, startsWith('custom_'));
      expect(added.name, 'Protein shake');
      expect(added.isCustom, isTrue);
      // The repository hands a FoodModel to the persisted datasource; the
      // entity returned to callers carries the same generated id.
      expect(added, isA<FoodModel>());
      expect((added as FoodModel).createdAt, isNotNull);
      expect(written!.id, added.id);
      verifyNever(() => persisted.writeCatalog(any()));
    });

    test('rejects an empty name with ValidationFailure', () async {
      final result = await repo.addCustomFood(
        Food(
          id: '',
          name: '   ',
          category: 'Protein',
          measurementType: MeasurementType.gram,
          caloriesPerGram: 0.9,
          caloriesPerPiece: null,
        ),
      );

      expect(result.getLeft().toNullable(), isA<ValidationFailure>());
      verifyNever(() => persisted.writeCustomFoods(any()));
    });
  });

  group('updateCustomFood', () {
    test('updates an existing custom food', () async {
      final existing = FoodModel(
        id: 'custom_1',
        name: 'Old name',
        category: 'Protein',
        measurementType: MeasurementType.gram,
        caloriesPerGram: 0.9,
        caloriesPerPiece: null,
        isCustom: true,
        createdAt: '2024-01-01T00:00:00.000',
      );
      when(() => persisted.readCustomFoods())
          .thenAnswer((_) async => [existing]);

      final result = await repo.updateCustomFood(
        existing.copyWith(name: 'New name'),
      );

      expect(result.isRight(), isTrue);
      expect(result.getRight().toNullable()!.name, 'New name');
      verify(() => persisted.writeCustomFoods(any())).called(1);
    });

    test('fails with NotFoundFailure when food is not a custom food', () async {
      when(() => persisted.readCustomFoods())
          .thenAnswer((_) async => <FoodModel>[]);

      final result = await repo.updateCustomFood(seedFood);

      expect(result.getLeft().toNullable(), isA<NotFoundFailure>());
      verifyNever(() => persisted.writeCustomFoods(any()));
    });
  });

  group('deleteCustomFood', () {
    test('removes the custom food and persists', () async {
      final existing = FoodModel(
        id: 'custom_1',
        name: 'Protein shake',
        category: 'Protein',
        measurementType: MeasurementType.gram,
        caloriesPerGram: 0.9,
        caloriesPerPiece: null,
        isCustom: true,
        createdAt: '2024-01-01T00:00:00.000',
      );
      when(() => persisted.readCustomFoods())
          .thenAnswer((_) async => [existing]);

      final result = await repo.deleteCustomFood('custom_1');

      expect(result.isRight(), isTrue);
      verify(() => persisted.writeCustomFoods([])).called(1);
    });

    test('fails with NotFoundFailure when id is not a custom food', () async {
      when(() => persisted.readCustomFoods())
          .thenAnswer((_) async => <FoodModel>[]);

      final result = await repo.deleteCustomFood('custom_1');

      expect(result.getLeft().toNullable(), isA<NotFoundFailure>());
      verifyNever(() => persisted.writeCustomFoods(any()));
    });
  });
}