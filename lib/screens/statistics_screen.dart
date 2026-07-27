import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/meal.dart';
import '../services/calorie_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _loading = true;
  List<Meal> _allMeals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _loading = true);
    final meals = await DBHelper.instance.getAllMeals();
    setState(() {
      _allMeals = meals;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final today = CalorieService.totalCalories(
        CalorieService.mealsForDay(_allMeals, DateTime.now()));
    final thisWeek =
        CalorieService.totalCalories(CalorieService.mealsThisWeek(_allMeals));
    final thisMonth =
        CalorieService.totalCalories(CalorieService.mealsThisMonth(_allMeals));
    final allTime = CalorieService.totalCalories(_allMeals);
    final avg7 = CalorieService.averagePerDay(_allMeals, 7);
    final avg30 = CalorieService.averagePerDay(_allMeals, 30);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: RefreshIndicator(
        onRefresh: _loadMeals,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatCard(label: 'Today', value: today),
            _StatCard(label: 'This Week', value: thisWeek),
            _StatCard(label: 'This Month', value: thisMonth),
            _StatCard(label: 'All Time', value: allTime),
            _StatCard(label: '7-Day Average', value: avg7, suffix: ' kcal/day'),
            _StatCard(
                label: '30-Day Average', value: avg30, suffix: ' kcal/day'),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final String suffix;

  const _StatCard(
      {required this.label, required this.value, this.suffix = ' kcal'});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(
              '${value.toStringAsFixed(0)}$suffix',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
