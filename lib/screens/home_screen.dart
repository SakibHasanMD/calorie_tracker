import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/meal.dart';
import '../services/calorie_service.dart';
import '../widgets/meal_card.dart';
import 'add_food_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Meal> _todayMeals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayMeals();
  }

  Future<void> _loadTodayMeals() async {
    setState(() => _loading = true);
    final meals = await DBHelper.instance.getMealsForDate(DateTime.now());
    setState(() {
      _todayMeals = meals;
      _loading = false;
    });
  }

  Future<void> _deleteMeal(int id) async {
    await DBHelper.instance.deleteMeal(id);
    _loadTodayMeals();
  }

  Future<void> _openAddFood() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddFoodScreen()),
    );
    if (result == true) {
      _loadTodayMeals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = CalorieService.totalCalories(_todayMeals);

    return Scaffold(
      appBar: AppBar(title: const Text('Calorie Tracker')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTodayMeals,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Today's Calories",
                                style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                            Text(
                              '${totalCalories.toStringAsFixed(0)} kcal',
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Today's Foods",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  if (_todayMeals.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No foods logged yet today.')),
                    )
                  else
                    ..._todayMeals.map(
                      (meal) => MealCard(
                        meal: meal,
                        onDelete: () => _deleteMeal(meal.id!),
                      ),
                    ),
                  const SizedBox(height: 80), // room for the FAB
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddFood,
        child: const Icon(Icons.add),
      ),
    );
  }
}
