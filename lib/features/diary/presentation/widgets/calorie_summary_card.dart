import 'package:flutter/material.dart';

/// Today's intake vs. daily target. Inline-editable target.
class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({
    super.key,
    required this.totalCalories,
    required this.target,
    this.onTargetChanged,
  });

  final double totalCalories;
  final int? target;
  final ValueChanged<int>? onTargetChanged;

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
    final newValue = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Daily calorie target'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(suffixText: 'kcal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              Navigator.of(ctx).pop(value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newValue != null && newValue > 0) onTargetChanged?.call(newValue);
  }

  static String _formatInt(double v) => v.toStringAsFixed(0);
}
