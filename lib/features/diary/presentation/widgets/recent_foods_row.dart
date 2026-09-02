import 'package:flutter/material.dart';

import '../../domain/entities/diary_entry.dart';

/// Horizontally-scrolling row of recent foods, shown on the entry form so the
/// user can re-log a common food with one tap.
class RecentFoodsRow extends StatelessWidget {
  const RecentFoodsRow({
    super.key,
    required this.entries,
    this.onPick,
  });

  final List<DiaryEntry> entries;
  final void Function(DiaryEntry entry)? onPick;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _Chip(entry: entry, onTap: () => onPick?.call(entry));
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.entry, this.onTap});

  final DiaryEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.foodName,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${_format(entry.calories)} kcal',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  static String _format(double v) => v.toStringAsFixed(0);
}
