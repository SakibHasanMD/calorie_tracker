import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/food.dart';
import '../models/meal.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'calorie_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE foods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        caloriePerGram REAL,
        caloriePerPiece REAL,
        measurementType TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        foodId INTEGER NOT NULL,
        foodName TEXT NOT NULL,
        weight REAL,
        pieces INTEGER,
        calories REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await _seedFoods(db);
  }

  Future<void> _seedFoods(Database db) async {
    final batch = db.batch();
    for (final food in _initialFoods) {
      batch.insert('foods', food.toMap()..remove('id'));
    }
    await batch.commit(noResult: true);
  }

  Future<List<Food>> getAllFoods() async {
    final db = await database;
    final maps = await db.query('foods', orderBy: 'name ASC');
    return maps.map((m) => Food.fromMap(m)).toList();
  }

  Future<int> insertMeal(Meal meal) async {
    final db = await database;
    return await db.insert('meals', meal.toMap()..remove('id'));
  }

  Future<void> deleteMeal(int id) async {
    final db = await database;
    await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Meal>> getAllMeals() async {
    final db = await database;
    final maps = await db.query('meals', orderBy: 'createdAt DESC');
    return maps.map((m) => Meal.fromMap(m)).toList();
  }

  Future<List<Meal>> getMealsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final db = await database;
    final maps = await db.query(
      'meals',
      where: 'createdAt >= ? AND createdAt < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => Meal.fromMap(m)).toList();
  }
}

final List<Food> _initialFoods = [
  Food(
      name: 'White rice (uncooked)',
      caloriePerGram: 3.65,
      measurementType: 'gram'),
  Food(
      name: 'Brown rice (uncooked)',
      caloriePerGram: 3.70,
      measurementType: 'gram'),
  Food(
      name: 'Mosur dal (red lentils, dry)',
      caloriePerGram: 3.52,
      measurementType: 'gram'),
  Food(name: 'Mung dal (dry)', caloriePerGram: 3.47, measurementType: 'gram'),
  Food(
      name: 'Chola/Bengal gram (dry)',
      caloriePerGram: 3.64,
      measurementType: 'gram'),
  Food(name: 'Chickpeas (dry)', caloriePerGram: 3.64, measurementType: 'gram'),
  Food(
      name: 'Kidney beans (dry)',
      caloriePerGram: 3.33,
      measurementType: 'gram'),
  Food(name: 'Potato (raw)', caloriePerGram: 0.77, measurementType: 'gram'),
  Food(
      name: 'Sweet potato (raw)',
      caloriePerGram: 0.86,
      measurementType: 'gram'),
  Food(name: 'Onion (raw)', caloriePerGram: 0.40, measurementType: 'gram'),
  Food(name: 'Tomato (raw)', caloriePerGram: 0.18, measurementType: 'gram'),
  Food(name: 'Carrot (raw)', caloriePerGram: 0.41, measurementType: 'gram'),
  Food(name: 'Cucumber (raw)', caloriePerGram: 0.15, measurementType: 'gram'),
  Food(
      name: 'Cauliflower (raw)', caloriePerGram: 0.25, measurementType: 'gram'),
  Food(name: 'Cabbage (raw)', caloriePerGram: 0.25, measurementType: 'gram'),
  Food(name: 'Spinach (raw)', caloriePerGram: 0.23, measurementType: 'gram'),
  Food(name: 'Green chili', caloriePerGram: 0.40, measurementType: 'gram'),
  Food(name: 'Garlic', caloriePerGram: 1.49, measurementType: 'gram'),
  Food(name: 'Ginger', caloriePerGram: 0.80, measurementType: 'gram'),
  Food(
      name: 'Egg (large, whole)',
      caloriePerPiece: 72,
      measurementType: 'piece'),
  Food(name: 'Egg white', caloriePerPiece: 17, measurementType: 'piece'),
  Food(name: 'Egg yolk', caloriePerPiece: 55, measurementType: 'piece'),
  Food(
      name: 'Chicken breast (raw, skinless)',
      caloriePerGram: 1.20,
      measurementType: 'gram'),
  Food(
      name: 'Chicken thigh (raw, skinless)',
      caloriePerGram: 1.44,
      measurementType: 'gram'),
  Food(
      name: 'Whole chicken (raw, mixed meat)',
      caloriePerGram: 1.43,
      measurementType: 'gram'),
  Food(
      name: 'Chicken liver (raw)',
      caloriePerGram: 1.19,
      measurementType: 'gram'),
  Food(name: 'Beef (lean, raw)', caloriePerGram: 1.76, measurementType: 'gram'),
  Food(name: 'Mutton (raw)', caloriePerGram: 2.58, measurementType: 'gram'),
  Food(name: 'Rohu fish (raw)', caloriePerGram: 0.97, measurementType: 'gram'),
  Food(name: 'Hilsa (raw)', caloriePerGram: 2.73, measurementType: 'gram'),
  Food(name: 'Tilapia (raw)', caloriePerGram: 0.96, measurementType: 'gram'),
  Food(name: 'Shrimp (raw)', caloriePerGram: 0.85, measurementType: 'gram'),
  Food(
      name: 'Besan (gram flour)',
      caloriePerGram: 3.87,
      measurementType: 'gram'),
  Food(name: 'Corn flour', caloriePerGram: 3.81, measurementType: 'gram'),
  Food(
      name: 'Wheat flour (atta)',
      caloriePerGram: 3.64,
      measurementType: 'gram'),
  Food(name: 'Oats (dry)', caloriePerGram: 3.89, measurementType: 'gram'),
  Food(name: 'Bread', caloriePerGram: 2.65, measurementType: 'gram'),
  Food(name: 'Soybean oil', caloriePerGram: 8.84, measurementType: 'gram'),
  Food(name: 'Mustard oil', caloriePerGram: 8.84, measurementType: 'gram'),
  Food(name: 'Olive oil', caloriePerGram: 8.84, measurementType: 'gram'),
  Food(name: 'Butter', caloriePerGram: 7.17, measurementType: 'gram'),
  Food(name: 'Ghee', caloriePerGram: 8.84, measurementType: 'gram'),
  Food(name: 'Sugar', caloriePerGram: 4.00, measurementType: 'gram'),
  Food(name: 'Honey', caloriePerGram: 3.04, measurementType: 'gram'),
  Food(name: 'Banana', caloriePerGram: 0.89, measurementType: 'gram'),
  Food(name: 'Apple', caloriePerGram: 0.52, measurementType: 'gram'),
  Food(name: 'Orange', caloriePerGram: 0.47, measurementType: 'gram'),
  Food(name: 'Mango', caloriePerGram: 0.60, measurementType: 'gram'),
  Food(name: 'Papaya', caloriePerGram: 0.43, measurementType: 'gram'),
  Food(name: 'Milk (whole, ml)', caloriePerGram: 0.61, measurementType: 'gram'),
  Food(name: 'Yogurt (plain)', caloriePerGram: 0.61, measurementType: 'gram'),
  Food(name: 'Cheese (cheddar)', caloriePerGram: 4.02, measurementType: 'gram'),
  Food(name: 'Peanuts', caloriePerGram: 5.67, measurementType: 'gram'),
  Food(name: 'Almonds', caloriePerGram: 5.79, measurementType: 'gram'),
  Food(name: 'Cashews', caloriePerGram: 5.53, measurementType: 'gram'),
  Food(name: 'Dates (dried)', caloriePerGram: 2.82, measurementType: 'gram'),
];
