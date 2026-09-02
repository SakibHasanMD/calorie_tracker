import 'package:bloc_test/bloc_test.dart';
import 'package:calorie_tracker/core/error/failures.dart';
import 'package:calorie_tracker/features/diary/domain/entities/diary_entry.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/add_diary_entry.dart';
import 'package:calorie_tracker/features/diary/domain/usecases/update_diary_entry.dart';
import 'package:calorie_tracker/features/diary/presentation/cubit/diary_form_cubit.dart';
import 'package:calorie_tracker/features/diary/presentation/cubit/diary_form_state.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      DiaryEntry(
        id: null,
        foodId: '',
        foodName: '',
        measurementType: MeasurementType.gram,
        amount: 0,
        calories: 0,
        entryDate: '2024-01-01',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  });

  late MockAddDiaryEntry addEntry;
  late MockUpdateDiaryEntry updateEntry;

  const rice = Food(
    id: 'f1',
    name: 'Rice',
    category: 'Grains',
    measurementType: MeasurementType.gram,
    caloriesPerGram: 1.3,
    caloriesPerPiece: null,
  );

  setUp(() {
    addEntry = MockAddDiaryEntry();
    updateEntry = MockUpdateDiaryEntry();
  });

  DiaryFormCubit build({DiaryEntry? editing}) => DiaryFormCubit(
        addEntry: addEntry,
        updateEntry: updateEntry,
        editing: editing,
      );

  group('live calorie recalculation', () {
    test('selectFood then changeAmount multiplies correctly', () async {
      final cubit = build();
      cubit.selectFood(rice);
      cubit.changeAmount(100);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.food, rice);
      expect(cubit.state.amount, 100);
      expect(cubit.state.calories, closeTo(130, 0.001));
      await cubit.close();
    });
  });

  group('submit (add)', () {
    blocTest<DiaryFormCubit, DiaryFormState>(
      'emits submitting then saved on success',
      build: () {
        when(() => addEntry(any())).thenAnswer(
          (invocation) async => Right(
            invocation.positionalArguments.first as DiaryEntry,
          ),
        );
        return build();
      },
      act: (cubit) async {
        cubit.selectFood(rice);
        cubit.changeAmount(100);
        cubit.changeDate(DateTime(2024, 9, 15));
        await cubit.submit();
      },
      verify: (_) {
        verify(() => addEntry(any())).called(1);
      },
    );

    blocTest<DiaryFormCubit, DiaryFormState>(
      'emits submitting then error on failure',
      build: () {
        when(() => addEntry(any())).thenAnswer(
          (_) async => const Left(
            CacheFailure(message: 'write fail'),
          ),
        );
        return build();
      },
      act: (cubit) async {
        cubit.selectFood(rice);
        cubit.changeAmount(100);
        cubit.changeDate(DateTime(2024, 9, 15));
        await cubit.submit();
      },
      verify: (_) {
        verify(() => addEntry(any())).called(1);
      },
    );

    blocTest<DiaryFormCubit, DiaryFormState>(
      'rejects with error when no food selected',
      build: () => build(),
      act: (cubit) async {
        cubit.changeAmount(100);
        await cubit.submit();
      },
      verify: (_) {
        verifyNever(() => addEntry(any()));
      },
    );
  });

  group('submit (edit)', () {
    blocTest<DiaryFormCubit, DiaryFormState>(
      'routes to updateEntry when editingEntryId is set',
      build: () {
        when(() => updateEntry(any())).thenAnswer(
          (invocation) async => Right(
            invocation.positionalArguments.first as DiaryEntry,
          ),
        );
        return build(
          editing: DiaryEntry(
            id: 42,
            foodId: 'f1',
            foodName: 'Rice',
            measurementType: MeasurementType.gram,
            amount: 100,
            calories: 130,
            entryDate: '2024-09-15',
            createdAt: DateTime(2024, 9, 15),
            updatedAt: DateTime(2024, 9, 15),
          ),
        );
      },
      act: (cubit) async {
        cubit.selectFood(rice);
        cubit.changeAmount(200);
        await cubit.submit();
      },
      verify: (_) {
        verify(() => updateEntry(any())).called(1);
        verifyNever(() => addEntry(any()));
      },
    );
  });
}
