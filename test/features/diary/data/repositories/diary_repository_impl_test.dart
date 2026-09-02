import 'package:calorie_tracker/core/database/app_database.dart';
import 'package:calorie_tracker/features/diary/data/datasources/diary_local_datasource.dart';
import 'package:calorie_tracker/features/diary/data/repositories/diary_repository_impl.dart';
import 'package:calorie_tracker/features/diary/domain/entities/diary_entry.dart';
import 'package:calorie_tracker/features/food_catalog/domain/entities/food.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DiaryRepositoryImpl repo;

  setUp(() async {
    AppDatabase.overrideInstance(await AppDatabase.openInMemory());
    final ds = DiaryLocalDataSource();
    await ds.ensureTable();
    repo = DiaryRepositoryImpl(localDataSource: ds);
  });

  tearDown(() async {
    await AppDatabase.close();
  });

  DiaryEntry make({
    int? id,
    String foodId = 'f1',
    String foodName = 'Food',
    double amount = 100,
    double calories = 100,
    String entryDate = '2024-09-15',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime(2024, 9, 15, 10);
    return DiaryEntry(
      id: id,
      foodId: foodId,
      foodName: foodName,
      measurementType: MeasurementType.gram,
      amount: amount,
      calories: calories,
      entryDate: entryDate,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  test('add then getEntriesForDate returns the entry', () async {
    final result = await repo.addEntry(make());
    final saved = result.getRight().toNullable()!;
    expect(saved.id, isNotNull);

    final list = (await repo.getEntriesForDate('2024-09-15'))
        .getRight()
        .toNullable()!;
    expect(list.length, 1);
    expect(list.single.id, saved.id);
    expect(list.single.foodName, 'Food');
  });

  test('update changes amount and calories', () async {
    final saved = (await repo.addEntry(make(amount: 100, calories: 100)))
        .getRight()
        .toNullable()!;
    final updated = saved.copyWith(amount: 200, calories: 200);
    final result = await repo.updateEntry(updated);
    expect(result.isRight(), isTrue);
    final reloaded = (await repo.getEntriesForDate('2024-09-15'))
        .getRight()
        .toNullable()!
        .single;
    expect(reloaded.amount, 200);
    expect(reloaded.calories, 200);
  });

  test('update on unknown id returns NotFoundFailure', () async {
    final result = await repo.updateEntry(
      make(id: 999, amount: 50, calories: 50),
    );
    expect(result.getLeft().toNullable(), isNotNull);
  });

  test('delete removes the entry', () async {
    final saved = (await repo.addEntry(make())).getRight().toNullable()!;
    final deleteResult = await repo.deleteEntry(saved.id!);
    expect(deleteResult.isRight(), isTrue);
    final list = (await repo.getEntriesForDate('2024-09-15'))
        .getRight()
        .toNullable()!;
    expect(list, isEmpty);
  });

  test('getEntriesForRange across a month boundary', () async {
    await repo.addEntry(
      make(entryDate: '2024-08-30', createdAt: DateTime(2024, 8, 30)),
    );
    await repo.addEntry(
      make(entryDate: '2024-09-02', createdAt: DateTime(2024, 9, 2)),
    );
    await repo.addEntry(
      make(entryDate: '2024-09-20', createdAt: DateTime(2024, 9, 20)),
    );
    await repo.addEntry(
      make(entryDate: '2024-10-05', createdAt: DateTime(2024, 10, 5)),
    );

    final list = (await repo.getEntriesForRange('2024-09-01', '2024-09-30'))
        .getRight()
        .toNullable()!;
    expect(list.length, 2);
    expect(list.map((e) => e.entryDate), ['2024-09-02', '2024-09-20']);
  });

  test('getRecentFoods dedupes and orders by most recent createdAt', () async {
    await repo.addEntry(make(
      foodId: 'f1',
      foodName: 'Rice',
      createdAt: DateTime(2024, 9, 1),
    ));
    await repo.addEntry(make(
      foodId: 'f2',
      foodName: 'Egg',
      createdAt: DateTime(2024, 9, 5),
    ));
    await repo.addEntry(make(
      foodId: 'f1',
      foodName: 'Rice',
      createdAt: DateTime(2024, 9, 10),
    ));
    await repo.addEntry(make(
      foodId: 'f3',
      foodName: 'Bread',
      createdAt: DateTime(2024, 9, 15),
    ));

    final list = (await repo.getRecentFoods(5)).getRight().toNullable()!;
    expect(list.length, 3);
    expect(list.map((e) => e.foodId), ['f3', 'f1', 'f2']);
  });

  test('getRecentFoods respects the limit', () async {
    for (final id in ['a', 'b', 'c', 'd']) {
      await repo.addEntry(make(foodId: id, foodName: 'F-$id'));
    }
    final list = (await repo.getRecentFoods(2)).getRight().toNullable()!;
    expect(list.length, 2);
  });
}
