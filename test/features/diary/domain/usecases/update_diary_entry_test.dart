import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/entities/diary_entry.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/update_diary_entry.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  late MockDiaryRepository repository;
  late UpdateDiaryEntry usecase;

  final entry = DiaryEntry(
    id: 1,
    foodId: 'seed_0001',
    foodName: 'White rice',
    measurementType: MeasurementType.gram,
    amount: 200,
    calories: 260,
    entryDate: '2024-09-01',
    createdAt: DateTime(2024, 9, 1),
    updatedAt: DateTime(2024, 9, 1),
  );

  setUp(() {
    repository = MockDiaryRepository();
    usecase = UpdateDiaryEntry(repository: repository);
  });

  test('calls repository.updateEntry and passes through', () async {
    when(() => repository.updateEntry(entry))
        .thenAnswer((_) async => Right(entry));

    final result = await usecase.call(entry);

    expect(result.isRight(), isTrue);
    verify(() => repository.updateEntry(entry)).called(1);
  });

  test('passes through a failure', () async {
    const failure = NotFoundFailure(message: 'gone');
    when(() => repository.updateEntry(entry))
        .thenAnswer((_) async => const Left(failure));

    final result = await usecase.call(entry);

    expect(result.isLeft(), isTrue);
    expect(result.getLeft().toNullable(), failure);
  });
}
