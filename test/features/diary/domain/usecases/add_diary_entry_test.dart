import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/entities/diary_entry.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/add_diary_entry.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockDiaryRepository repository;
  late AddDiaryEntry usecase;

  final draftEntry = DiaryEntry(
    id: null,
    foodId: 'seed_0001',
    foodName: 'White rice',
    measurementType: MeasurementType.gram,
    amount: 100,
    calories: 130,
    entryDate: '2024-09-01',
    createdAt: DateTime(2024, 9, 1),
    updatedAt: DateTime(2024, 9, 1),
  );

  setUp(() {
    repository = MockDiaryRepository();
    usecase = AddDiaryEntry(repository: repository);
  });

  test('calls repository.addEntry and passes through the saved entry', () async {
    final saved = draftEntry.copyWith(id: 1);
    when(() => repository.addEntry(draftEntry))
        .thenAnswer((_) async => Right(saved));

    final result = await usecase.call(draftEntry);

    expect(result.isRight(), isTrue);
    expect(result.getRight().toNullable()!.id, 1);
    verify(() => repository.addEntry(draftEntry)).called(1);
  });

  test('passes through a failure', () async {
    const failure = CacheFailure(message: 'db full');
    when(() => repository.addEntry(draftEntry))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call(draftEntry);

    expect(result.isLeft(), isTrue);
    expect(result.getLeft().toNullable(), failure);
    verify(() => repository.addEntry(draftEntry)).called(1);
  });
}
