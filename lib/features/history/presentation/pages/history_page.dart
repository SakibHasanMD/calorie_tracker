import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../diary/presentation/cubit/daily_diary_cubit.dart';
import '../../domain/entities/calendar_summary.dart';
import '../cubit/history_cubit.dart';
import '../cubit/history_state.dart';
import '../widgets/day_summary_tile.dart';
import '../widgets/period_selector.dart';
import 'day_detail_page.dart';

/// The History tab (Track 5): browse diary totals by day / week / month /
/// year and drill into any day.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryCubit>(
      create: (_) => Injector.getIt<HistoryCubit>()..load(),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  void _openDay(BuildContext context, HistoryCubit cubit, DateTime day) {
    final dailyDiaryCubit = Injector.getIt<DailyDiaryCubit>()
      ..load(_formatDate(day));
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DayDetailPage(
          date: day,
          dailyDiaryCubit: dailyDiaryCubit,
        ),
      ),
    );
  }

  void _onBucketTap(
    BuildContext context,
    HistoryCubit cubit,
    CalendarSummary summary,
    CalendarBucket bucket,
  ) {
    if (summary.period == CalendarPeriod.year) {
      // Tapping a month drills into that month's day-level view.
      cubit.changePeriod(CalendarPeriod.month).then((_) {
        if (context.mounted) cubit.jumpToDate(bucket.date);
      });
    } else {
      _openDay(context, cubit, bucket.date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HistoryCubit>();
    return BlocBuilder<HistoryCubit, HistoryState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('History'),
            actions: [
              IconButton(
                icon: const Icon(Icons.today_outlined),
                tooltip: 'Go to today',
                onPressed: () => cubit.jumpToDate(DateTime.now()),
              ),
            ],
          ),
          body: switch (state.status) {
            HistoryStatus.initial ||
            HistoryStatus.loading =>
              const LoadingView(message: 'Loading history…'),
            HistoryStatus.error => ErrorView(
                failure:
                    state.failure as Failure? ?? const UnexpectedFailure(),
                onRetry: cubit.load,
              ),
            HistoryStatus.loaded => _buildLoaded(context, cubit, state),
          },
        );
      },
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    HistoryCubit cubit,
    HistoryState state,
  ) {
    final summary = state.summary!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: PeriodSelector(
                  period: state.period,
                  onChanged: cubit.changePeriod,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous',
              onPressed: cubit.goToPrevious,
            ),
            Text(
              _rangeLabel(summary),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next',
              onPressed: cubit.goToNext,
            ),
          ],
        ),
        const Divider(height: 1),
        Expanded(
          child: summary.buckets.isEmpty
              ? const EmptyView(
                  title: 'Nothing here',
                  message: 'No data in this period.',
                )
              : ListView.builder(
                  itemCount: summary.buckets.length,
                  itemBuilder: (context, index) {
                    final bucket = summary.buckets[index];
                    return DaySummaryTile(
                      bucket: bucket,
                      period: state.period,
                      onTap: () => _onBucketTap(context, cubit, summary, bucket),
                    );
                  },
                ),
        ),
      ],
    );
  }

  static String _rangeLabel(CalendarSummary summary) {
    final start = summary.startDate;
    final end = summary.endDate;
    if (start == end) return _pretty(start);
    return '${_pretty(start)} – ${_pretty(end)}';
  }

  static String _pretty(String yyyyMmDd) {
    final parts = yyyyMmDd.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $day, $year';
  }
}

String _formatDate(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}
