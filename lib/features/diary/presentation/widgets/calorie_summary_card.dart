import 'package:flutter/material.dart';

import '../../../home/domain/entities/calorie_target_scope.dart';

/// Today's (or a viewed date's) intake vs. its daily target. Inline-editable
/// target with a scope choice (day / week / month / year) so a change can be
/// applied to a whole period at once.
class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({
    super.key,
    required this.totalCalories,
    required this.target,
    this.onTargetChanged,
  });

  final double totalCalories;
  final int? target;
  final void Function(int value, CalorieTargetScope scope)? onTargetChanged;

  @override
  Widget build(BuildContext context) {
    final targetText = target?.toString() ?? '—';
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatInt(totalCalories),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    target == null
                        ? 'No daily target set'
                        : '/ $targetText kcal',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (onTargetChanged != null)
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Set target'),
                onPressed: () => _editTarget(context),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTarget(BuildContext context) async {
    final controller = TextEditingController(text: target?.toString() ?? '');
    var scope = CalorieTargetScope.day;
    final newValue = await showDialog<(int, CalorieTargetScope)?>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Daily calorie target'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: const InputDecoration(suffixText: 'kcal'),
              ),
              const SizedBox(height: 16),
              Text('Apply to', style: Theme.of(ctx).textTheme.labelLarge),
              const SizedBox(height: 8),
              SegmentedButton<CalorieTargetScope>(
                segments: const [
                  ButtonSegment(
                    value: CalorieTargetScope.day,
                    label: Text('Day'),
                  ),
                  ButtonSegment(
                    value: CalorieTargetScope.week,
                    label: Text('Week'),
                  ),
                  ButtonSegment(
                    value: CalorieTargetScope.month,
                    label: Text('Month'),
                  ),
                  ButtonSegment(
                    value: CalorieTargetScope.year,
                    label: Text('Year'),
                  ),
                ],
                selected: {scope},
                showSelectedIcon: false,
                onSelectionChanged: (selection) {
                  setDialogState(() => scope = selection.first);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                if (value == null) {
                  Navigator.of(ctx).pop(null);
                  return;
                }
                Navigator.of(ctx).pop((value, scope));
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    if (newValue != null && newValue.$1 > 0) {
      onTargetChanged?.call(newValue.$1, newValue.$2);
    }
  }

  static String _formatInt(double v) => v.toStringAsFixed(0);
}