import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/target_summary_card.dart';

/// The Statistics tab: today / week / month / all-time totals (with target
/// comparison) and 7-day / 30-day averages.
class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatisticsCubit>(
      create: (_) => Injector.getIt<StatisticsCubit>()..load(),
      child: const _StatisticsView(),
    );
  }
}

class _StatisticsView extends StatelessWidget {
  const _StatisticsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        // Refresh is available via pull-to-refresh on the list below.
      ),
      body: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          switch (state.status) {
            case StatisticsStatus.initial:
            case StatisticsStatus.loading:
              return const LoadingView(message: 'Calculating statistics…');
            case StatisticsStatus.error:
              return ErrorView(
                failure: state.failure as Failure? ?? const UnexpectedFailure(),
                onRetry: () => context.read<StatisticsCubit>().load(),
              );
            case StatisticsStatus.loaded:
              final s = state.statistics!;
              return RefreshIndicator(
                onRefresh: () => context.read<StatisticsCubit>().load(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  children: [
                    const _SectionLabel('Totals'),
                    TargetSummaryCard(
                      label: 'Today',
                      icon: Icons.today_outlined,
                      consumed: s.todayCalories,
                      target: s.todayTarget.toDouble(),
                    ),
                    TargetSummaryCard(
                      label: 'This week',
                      icon: Icons.date_range_outlined,
                      consumed: s.weekCalories,
                      target: s.weekTarget.toDouble(),
                    ),
                    TargetSummaryCard(
                      label: 'This month',
                      icon: Icons.calendar_month_outlined,
                      consumed: s.monthCalories,
                      target: s.monthTarget.toDouble(),
                    ),
                    TargetSummaryCard(
                      label: 'All time',
                      icon: Icons.history_outlined,
                      consumed: s.allTimeCalories,
                      target: s.allTimeTarget.toDouble(),
                    ),
                    const _SectionLabel('Averages'),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: '7-day average',
                            value: '${s.sevenDayAverage.toStringAsFixed(0)} kcal',
                            icon: Icons.trending_up,
                          ),
                        ),
                        Expanded(
                          child: StatCard(
                            label: '30-day average',
                            value:
                                '${s.thirtyDayAverage.toStringAsFixed(0)} kcal',
                            icon: Icons.trending_up,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
