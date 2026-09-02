import 'package:calorie_tracker/features/home/data/datasources/calorie_target_local_datasource.dart';
import 'package:calorie_tracker/features/home/data/repositories/calorie_target_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    test('returns the stored target', () async {
      when(() => dataSource.read()).thenAnswer((_) async => 1800);
      final result = await repository.getTarget();
      expect(result.isRight(), isTrue);
      expect(result.getRight().toNullable(), 1800);
    });

    test('maps a storage failure to a CacheFailure', () async {
      when(() => dataSource.read()).thenThrow(Exception('boom'));
      final result = await repository.getTarget();
      expect(result.isLeft(), isTrue);
    });
  });

  group('setTarget', () {
    test('writes a valid target', () async {
      when(() => dataSource.write(2000)).thenAnswer((_) async {});
      final result = await repository.setTarget(2000);
      expect(result.isRight(), isTrue);
      verify(() => dataSource.write(2000)).called(1);
    });

    test('rejects a non-positive target', () async {
      final result = await repository.setTarget(0);
      expect(result.isLeft(), isTrue);
      verifyNever(() => dataSource.write(any()));
    });

    test('maps a storage failure to a CacheFailure', () async {
      when(() => dataSource.write(2000)).thenThrow(Exception('boom'));
      final result = await repository.setTarget(2000);
      expect(result.isLeft(), isTrue);
    });
  });

  group('local datasource integration', () {
    test('defaults to 2000 before any target is set', () async {
      SharedPreferences.setMockInitialValues({});
      final ds = CalorieTargetLocalDataSource();
      expect(await ds.read(), CalorieTargetLocalDataSource.defaultTarget);
    });

    test('round-trips a target through SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final ds = CalorieTargetLocalDataSource();
      await ds.write(2400);
      expect(await ds.read(), 2400);
    });
  });
}
