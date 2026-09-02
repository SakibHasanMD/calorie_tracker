import 'dart:io';

import 'package:calorie_tracker/core/storage/app_paths.dart';
import 'package:calorie_tracker/features/home/data/datasources/calorie_target_local_datasource.dart';
import 'package:calorie_tracker/features/home/data/repositories/calorie_target_repository_impl.dart';
import 'package:calorie_tracker/features/home/domain/entities/calorie_target_scope.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockCalorieTargetLocalDataSource dataSource;
  late CalorieTargetRepositoryImpl repository;

  setUp(() {
    dataSource = MockCalorieTargetLocalDataSource();
    repository = CalorieTargetRepositoryImpl(dataSource: dataSource);
  });

  group('getTarget', () {
    test('returns the stored target for the requested date', () async {
      when(() => dataSource.readAll()).thenAnswer(
        (_) async => {'2024-09-26': 1800, '2024-09-27': 2000},
      );
      final result = await repository.getTarget('2024-09-26');
      expect(result.isRight(), isTrue);
      expect(result.getRight().toNullable(), 1800);
    });

    test('falls back to the default for an unset date', () async {
      when(() => dataSource.readAll()).thenAnswer((_) async => {});
      final result = await repository.getTarget('2024-09-26');
      expect(result.getRight().toNullable(),
          CalorieTargetLocalDataSource.defaultTarget);
    });

    test('maps a storage failure to a CacheFailure', () async {
      when(() => dataSource.readAll()).thenThrow(Exception('boom'));
      final result = await repository.getTarget('2024-09-26');
      expect(result.isLeft(), isTrue);
    });
  });

  group('setTarget (day scope)', () {
    test('writes a valid target for exactly one day', () async {
      when(() => dataSource.readAll()).thenAnswer((_) async => {});
      when(() => dataSource.writeAll(any())).thenAnswer((_) async {});
      final result = await repository.setTarget(
        '2024-09-26',
        2000,
        CalorieTargetScope.day,
      );
      expect(result.isRight(), isTrue);
      final captured =
          verify(() => dataSource.writeAll(captureAny())).captured.single
              as Map<String, int>;
      expect(captured, {'2024-09-26': 2000});
    });

    test('rejects a non-positive target', () async {
      final result = await repository.setTarget(
        '2024-09-26',
        0,
        CalorieTargetScope.day,
      );
      expect(result.isLeft(), isTrue);
      verifyNever(() => dataSource.writeAll(any()));
    });

    test('maps a storage failure to a CacheFailure', () async {
      when(() => dataSource.readAll()).thenAnswer((_) async => {});
      when(() => dataSource.writeAll(any())).thenThrow(Exception('boom'));
      final result = await repository.setTarget(
        '2024-09-26',
        2000,
        CalorieTargetScope.day,
      );
      expect(result.isLeft(), isTrue);
    });
  });

  group('setTarget (per-scope fill)', () {
    test('week scope fills the Sat-Fri week containing the date', () async {
      // 2024-09-26 (Thu) → Sat 2024-09-21 .. Fri 2024-09-27.
      when(() => dataSource.readAll()).thenAnswer((_) async => {});
      when(() => dataSource.writeAll(any())).thenAnswer((_) async {});
      await repository.setTarget(
        '2024-09-26',
        1750,
        CalorieTargetScope.week,
      );
      final map =
          verify(() => dataSource.writeAll(captureAny())).captured.single
              as Map<String, int>;
      expect(map.length, 7);
      expect(map['2024-09-21'], 1750);
      expect(map['2024-09-26'], 1750);
      expect(map['2024-09-27'], 1750);
    });

    test('month scope fills only the calendar month of the date', () async {
      when(() => dataSource.readAll()).thenAnswer(
        (_) async => {'2024-08-15': 2000},
      );
      when(() => dataSource.writeAll(any())).thenAnswer((_) async {});
      await repository.setTarget(
        '2024-09-26',
        1600,
        CalorieTargetScope.month,
      );
      final map =
          verify(() => dataSource.writeAll(captureAny())).captured.single
              as Map<String, int>;
      // 30 days in September, 2024.
      expect(map.length, 31);
      expect(map['2024-09-01'], 1600);
      expect(map['2024-09-30'], 1600);
      // Other months untouched.
      expect(map['2024-08-15'], 2000);
      expect(map.containsKey('2024-10-01'), isFalse);
    });

    test('year scope fills only the calendar year of the date', () async {
      when(() => dataSource.readAll())
          .thenAnswer((_) async => {'2023-12-31': 2000});
      when(() => dataSource.writeAll(any())).thenAnswer((_) async {});
      await repository.setTarget(
        '2024-09-26',
        1500,
        CalorieTargetScope.year,
      );
      final map =
          verify(() => dataSource.writeAll(captureAny())).captured.single
              as Map<String, int>;
      // 2024 is a leap year → 366 days. The unrelated 2023 entry is preserved.
      expect(map.length, 366 + 1);
      expect(map['2023-12-31'], 2000);
      expect(map['2024-01-01'], 1500);
      expect(map['2024-12-31'], 1500);
    });
  });

  group('local datasource (real files, temp dir)', () {
    late Directory tempDir;
    late CalorieTargetLocalDataSource ds;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('calorie_targets_');
      AppPaths.overrideForTesting(tempDir.path);
      ds = CalorieTargetLocalDataSource();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('reads defaults when the file is missing', () async {
      expect(await ds.readAll(), isEmpty);
    });

    test('round-trips a targets map to disk', () async {
      await ds.writeAll({'2024-09-26': 1800, '2024-09-27': 2000});
      expect(await ds.readAll(), {'2024-09-26': 1800, '2024-09-27': 2000});
    });
  });
}