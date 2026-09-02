import 'package:flutter/material.dart';

import '../../domain/entities/food.dart';

/// A tile that shows one food's name, category and per-measurement calories.
class FoodListTile extends StatelessWidget {
  const FoodListTile({super.key, required this.food, this.onTap, this.trailing});

  final Food food;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final perLabel = food.measurementType == MeasurementType.gram
        ? '${_fmt(food.caloriesPerGram)} kcal/g'
        : '${_fmt(food.caloriesPerPiece)} kcal/piece';

    final subtitle = '${food.category} • $perLabel'
        '${food.isCustom ? ' • Custom' : ''}';

    return ListTile(
      leading: const Icon(Icons.restaurant_menu),
      title: Text(food.name),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  String _fmt(double? value) {
    if (value == null) return '—';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}