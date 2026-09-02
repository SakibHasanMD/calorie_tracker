import 'package:flutter/material.dart';

import '../../domain/entities/diary_entry.dart';

/// Compact list tile for a single diary entry. Tap → edit (handled by the
/// caller via [onTap]). Trailing delete affordance is optional so this widget
/// is reusable on Home (swipe) and Day Detail (explicit button).
class DiaryEntryTile extends StatelessWidget {
  const DiaryEntryTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  final DiaryEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final amountLabel = entry.measurementType.name == 'gram'
        ? '${_formatAmount(entry.amount)} g'
        : '${_formatAmount(entry.amount)} pcs';
    return ListTile(
      onTap: onTap,
      title: Text(entry.foodName),
      subtitle: Text(amountLabel),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_formatAmount(entry.calories)} kcal',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: onDelete,
            ),
          ],
        ],
      ),
    );
  }

  static String _formatAmount(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toStringAsFixed(1);
  }
}
