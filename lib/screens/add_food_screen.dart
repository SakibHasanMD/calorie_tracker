import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/food.dart';
import '../models/meal.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  List<Food> _foods = [];
  Food? _selectedFood;
  final TextEditingController _amountController = TextEditingController();
  double _calculatedCalories = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFoods();
    _amountController.addListener(_recalculate);
  }

  Future<void> _loadFoods() async {
    final foods = await DBHelper.instance.getAllFoods();
    setState(() {
      _foods = foods;
      _selectedFood = foods.isNotEmpty ? foods.first : null;
      _loading = false;
    });
  }

  void _recalculate() {
    final amount = double.tryParse(_amountController.text);
    final food = _selectedFood;
    if (amount == null || food == null) {
      setState(() => _calculatedCalories = 0);
      return;
    }
    if (food.isGramBased) {
      setState(() => _calculatedCalories = amount * (food.caloriePerGram ?? 0));
    } else {
      setState(
          () => _calculatedCalories = amount * (food.caloriePerPiece ?? 0));
    }
  }

  Future<void> _save() async {
    final food = _selectedFood;
    final amount = double.tryParse(_amountController.text);

    if (food == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a food and enter a valid amount.')),
      );
      return;
    }

    final meal = Meal(
      foodId: food.id!,
      foodName: food.name,
      weight: food.isGramBased ? amount : null,
      pieces: food.isGramBased ? null : amount.round(),
      calories: _calculatedCalories,
      createdAt: DateTime.now(),
    );

    await DBHelper.instance.insertMeal(meal);

    if (mounted) {
      Navigator.pop(context, true); // return true so Home screen refreshes
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isGram = _selectedFood?.isGramBased ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Food')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Food',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Food>(
              initialValue: _selectedFood,
              isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _foods
                  .map((f) => DropdownMenuItem(value: f, child: Text(f.name)))
                  .toList(),
              onChanged: (food) {
                setState(() {
                  _selectedFood = food;
                  _amountController.clear();
                  _calculatedCalories = 0;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              isGram ? 'Weight (grams)' : 'Pieces',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: isGram ? 'e.g. 150' : 'e.g. 2',
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Calories',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${_calculatedCalories.toStringAsFixed(1)} kcal',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
