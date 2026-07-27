import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/meal.dart';
import '../services/calorie_service.dart';
import '../widgets/meal_card.dart';

class DayDetailScreen extends StatefulWidget {
  final DateTime date;
  final String dayLabel;

  const DayDetailScreen(
      {super.key, required this.date, required this.dayLabel});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  List<Meal> _meals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _loading = true);
    final meals = await DBHelper.instance.getMealsForDate(widget.date);
    setState(() {
      _meals = meals;
      _loading = false;
    });
  }

  Future<void> _deleteMeal(int id) async {
    await DBHelper.instance.deleteMeal(id);
    _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    final total = CalorieService.totalCalories(_meals);

    return Scaffold(
      appBar: AppBar(title: Text(widget.dayLabel)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _meals.isEmpty
                      ? const Center(child: Text('No entries for this day.'))
                      : ListView(
                          children: _meals
                              .map((meal) => MealCard(
                                    meal: meal,
                                    onDelete: () => _deleteMeal(meal.id!),
                                  ))
                              .toList(),
                        ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '${total.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
