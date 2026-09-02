import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/calendar_summary.dart';

/// A single row in the History list: one bucket (a day, or a month in the
/// year view) with its calorie total. Tapping opens the day detail (or, for a
/// month bucket, jumps into that month).
class DaySummaryTile extends StatelessWidget {
  const DaySummaryTile({
    super.key,
    required this.bucket,
    required this.period,
    this.onTap,
  });

  final CalendarBucket bucket;
  final CalendarPeriod period;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final label = period == CalendarPeriod.year
        ? DateFormat('MMMM yyyy').format(bucket.date)
        : DateFormat('EEE, MMM d').format(bucket.date);
    final calories = bucket.calories.toStringAsFixed(0);
    return ListTile(
      onTap: onTap,
      leading: const Icon(Icons.local_fire_department_outlined),
      title: Text(label),
      trailing: Text(
        '$calories kcal',
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}
