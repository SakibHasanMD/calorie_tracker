import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../diary/domain/entities/diary_entry.dart';
import '../../../diary/domain/usecases/delete_diary_entry.dart';
import '../../../diary/presentation/cubit/daily_diary_cubit.dart';
import '../../../diary/presentation/cubit/daily_diary_state.dart';
import '../../../diary/presentation/pages/entry_form_page.dart';
import '../../../diary/presentation/widgets/calorie_summary_card.dart';
import '../../../diary/presentation/widgets/diary_entry_tile.dart';
import '../../../home/domain/entities/calorie_target_scope.dart';
import '../../../home/domain/usecases/get_calorie_target.dart';
import '../../../home/domain/usecases/set_calorie_target.dart';

/// All entries for one specific date. Reuses the diary `DailyDiaryCubit`.
///
/// Add opens `entry_form_page` prefilled for [date]; tapping an entry opens it
/// in edit mode. Deleting is supported directly here (and swipe-to-delete on
/// the tile). This is what provides "add/edit on a specific date".
///
/// The summary card shows the effective calorie target *for this date*
/// (defaulting to 2000 when unset) and lets the user set a target for the
/// scope they choose — including filling a whole missed past week/month.
class DayDetailPage extends StatefulWidget {
  const DayDetailPage({
    super.key,
    required this.date,
    required this.dailyDiaryCubit,
  });

  final DateTime date;
  final DailyDiaryCubit dailyDiaryCubit;

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage> {
  int? _target;

  String get _dateString => _formatDate(widget.date);

  @override
  void initState() {
    super.initState();
    _loadTarget();
  }

  Future<void> _loadTarget() async {
    final result =
        await Injector.getIt<GetCalorieTarget>().call(_dateString);
    if (!mounted) return;
    setState(() => _target = result.getRight().toNullable());
  }

  Future<void> _setTarget(int value, CalorieTargetScope scope) async {
    final result = await Injector.getIt<SetCalorieTarget>()
        .call(_dateString, value, scope);
    if (!mounted) return;
    if (result.isRight()) {
      setState(() => _target = value);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.getLeft().toNullable()?.message ?? '')),
      );
    }
  }

  Future<void> _deleteEntry(BuildContext context, DiaryEntry entry) async {
    final result = await Injector.getIt<DeleteDiaryEntry>().call(entry.id!);
    if (!context.mounted) return;
    if (result.isRight()) {
      await widget.dailyDiaryCubit.load(_dateString);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete entry')),
      );
    }
  }

  void _openEntry(BuildContext context, {DiaryEntry? entry}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EntryFormPage(
          date: widget.date,
          existingEntry: entry,
          dailyDiaryCubit: widget.dailyDiaryCubit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DailyDiaryCubit, DailyDiaryState>(
      bloc: widget.dailyDiaryCubit,
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_formatDateLong(widget.date)),
          ),
          body: switch (state.status) {
            DailyDiaryStatus.initial ||
            DailyDiaryStatus.loading =>
              const LoadingView(message: 'Loading entries…'),
            DailyDiaryStatus.error => ErrorView(
                failure:
                    state.failure as Failure? ?? const UnexpectedFailure(),
                onRetry: () => widget.dailyDiaryCubit.load(_dateString),
              ),
            DailyDiaryStatus.loaded => state.entries.isEmpty
                ? const EmptyView(
                    title: 'No entries this day',
                    message: 'Tap + to add one.',
                  )
                : ListView(
                    children: [
                      CalorieSummaryCard(
                        totalCalories: state.totalCalories,
                        target: _target,
                        onTargetChanged: _setTarget,
                      ),
                      ...state.entries.map(
                        (entry) => Dismissible(
                          key: ValueKey(entry.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Theme.of(context).colorScheme.error,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: Icon(
                              Icons.delete_outline,
                              color: Theme.of(context).colorScheme.onError,
                            ),
                          ),
                          onDismissed: (_) => _deleteEntry(context, entry),
                          child: DiaryEntryTile(
                            entry: entry,
                            onTap: () => _openEntry(context, entry: entry),
                            onDelete: () => _deleteEntry(context, entry),
                          ),
                        ),
                      ),
                    ],
                  ),
          },
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openEntry(context),
            tooltip: 'Add entry',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  static String _formatDate(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  static String _formatDateLong(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}