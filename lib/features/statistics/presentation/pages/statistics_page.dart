import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../cubit/statistics_cubit.dart';
import '../cubit/statistics_state.dart';
import '../widgets/stat_card.dart';

/// The Statistics tab (Track 6): today / week / month / all-time totals and
/// 7-day / 30-day averages.
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

  String _kcal(double v) => '${v.toStringAsFixed(0)} kcal';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => context.read<StatisticsCubit>().load(),
          ),
        ],
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
                    _SectionLabel('Totals'),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Today',
                            value: _kcal(s.todayCalories),
                            icon: Icons.today_outlined,
                          ),
                        ),
                        Expanded(
                          child: StatCard(
                            label: 'This week',
                            value: _kcal(s.weekCalories),
                            icon: Icons.date_range_outlined,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'This month',
                            value: _kcal(s.monthCalories),
                            icon: Icons.calendar_month_outlined,
                          ),
                        ),
                        Expanded(
                          child: StatCard(
                            label: 'All time',
                            value: _kcal(s.allTimeCalories),
                            icon: Icons.history_outlined,
                          ),
                        ),
                      ],
                    ),
                    _SectionLabel('Averages'),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: '7-day average',
                            value: _kcal(s.sevenDayAverage),
                            icon: Icons.trending_up,
                          ),
                        ),
                        Expanded(
                          child: StatCard(
                            label: '30-day average',
                            value: _kcal(s.thirtyDayAverage),
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
