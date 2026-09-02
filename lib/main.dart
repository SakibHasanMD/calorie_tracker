import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injector.dart';
import 'features/diary/data/datasources/diary_local_datasource.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Injector.setupLocator();
  // Ensure the diary table exists before any cubit asks for entries. Eager
  // here keeps table DDL colocated with the owning feature (diary), not in
  // the shared AppDatabase.
  await Injector.getIt<DiaryLocalDataSource>().ensureTable();
  runApp(const App());
}
