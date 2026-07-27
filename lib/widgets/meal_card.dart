import 'package:flutter/material.dart';
import '../models/meal.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onDelete;

  const MealCard({super.key, required this.meal, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(meal.foodName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${meal.amountLabel} • ${meal.calories.toStringAsFixed(0)} kcal'),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
