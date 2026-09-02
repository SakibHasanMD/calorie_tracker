import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:calorie_tracker/core/database/app_database.dart';

void main() {
  setUpAll(() {
    // Route the sqflite top-level openDatabase(...) (used internally by
    // AppDatabase) through the FFI factory so no emulator/device is needed.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  tearDown(() async {
    await AppDatabase.close();
    AppDatabase.overrideInstance(null);
  });

  test('opens the shared database at the configured schema version', () async {
    final db = await AppDatabase.instance();

    expect(db.isOpen, isTrue);
    expect(await db.getVersion(), AppDatabase.version);
  });

  test('supports basic CRUD round-trip in the shared database', () async {
    final db = await AppDatabase.instance();

    // AppDatabase intentionally owns no tables, so prove the handle works by
    // executing a trivial SQL statement against a throwaway table.
    await db.execute('CREATE TABLE smoke_test (id INTEGER)');
    await db.insert('smoke_test', {'id': 1});
    final rows = await db.query('smoke_test');
    expect(rows, hasLength(1));
    expect(rows.single['id'], 1);

    await db.execute('DROP TABLE smoke_test');
  });

  test('openInMemory returns a usable, isolated database', () async {
    final db = await AppDatabase.openInMemory();

    expect(db.isOpen, isTrue);
    expect(await db.getVersion(), AppDatabase.version);

    await db.execute('CREATE TABLE t (id INTEGER)');
    await db.close();
    expect(db.isOpen, isFalse);
  });
}