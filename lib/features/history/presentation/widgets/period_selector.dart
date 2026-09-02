import 'package:flutter/material.dart';

import '../../domain/entities/calendar_summary.dart';

/// Day / Week / Month / Year segmented toggle for the History screen.
class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.period,
    required this.onChanged,
  });

  final CalendarPeriod period;
  final ValueChanged<CalendarPeriod> onChanged;

  static const Map<CalendarPeriod, String> _labels = {
    CalendarPeriod.day: 'Day',
    CalendarPeriod.week: 'Week',
    CalendarPeriod.month: 'Month',
    CalendarPeriod.year: 'Year',
  };

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<CalendarPeriod>(
      segments: CalendarPeriod.values
          .map(
            (p) => ButtonSegment<CalendarPeriod>(
              value: p,
              label: Text(_labels[p]!),
            ),
          )
          .toList(),
      selected: {period},
      onSelectionChanged: (selection) => onChanged(selection.first),
      showSelectedIcon: false,
    );
  }
}
