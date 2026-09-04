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
import '../../../food_catalog/presentation/cubit/food_catalog_cubit.dart';
import '../../../food_catalog/presentation/pages/manage_foods_page.dart';
import '../../domain/entities/calorie_target_scope.dart';
import '../../domain/usecases/get_calorie_target.dart';
import '../../domain/usecases/set_calorie_target.dart';

/// The real Home tab (Track 4).
///
/// Shows today's total against the daily calorie target, today's entries with
/// swipe-to-delete and tap-to-edit, and a FAB to add an entry for today. The
/// manage-foods action formerly on the placeholder host page lives in the app
/// bar here.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DailyDiaryCubit _dailyDiaryCubit;
  int? _target;
  bool _loadingTarget = true;

  String get _today => _formatDate(DateTime.now());

  @override
  void initState() {
    super.initState();
    _dailyDiaryCubit =
        Injector.getIt<DailyDiaryCubit>()..load(_formatDate(DateTime.now()));
    _loadTarget();
  }

  Future<void> _loadTarget() async {
    final result = await Injector.getIt<GetCalorieTarget>().call(_today);
    if (!mounted) return;
    setState(() {
      _target = result.getRight().toNullable();
      _loadingTarget = false;
    });
  }

  Future<void> _setTarget(int value, CalorieTargetScope scope) async {
    final result =
        await Injector.getIt<SetCalorieTarget>().call(_today, value, scope);
    if (!mounted) return;
    if (result.isRight()) {
      setState(() => _target = value);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.getLeft().toNullable()?.message ?? ''),
        ),
      );
    }
  }

  Future<void> _deleteEntry(DiaryEntry entry) async {
    final result = await Injector.getIt<DeleteDiaryEntry>().call(entry.id!);
    if (!mounted) return;
    if (result.isRight()) {
      await _dailyDiaryCubit.load(_today);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete entry')),
      );
    }
  }

  void _openEntry({DateTime? date, DiaryEntry? entry}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EntryFormPage(
          date: date,
          existingEntry: entry,
          dailyDiaryCubit: _dailyDiaryCubit,
        ),
      ),
    );
  }

  void _openManageFoods() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: Injector.getIt<FoodCatalogCubit>()..loadFoods(),
          child: const ManageFoodsPage(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dailyDiaryCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Manage foods',
            onPressed: _openManageFoods,
          ),
        ],
      ),
      body: BlocBuilder<DailyDiaryCubit, DailyDiaryState>(
        bloc: _dailyDiaryCubit,
        builder: (context, state) {
          if (_loadingTarget || state.status == DailyDiaryStatus.loading) {
            return const LoadingView(message: 'Loading your diary…');
          }
          return RefreshIndicator(
            onRefresh: () => _dailyDiaryCubit.load(_today),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                CalorieSummaryCard(
                  totalCalories: state.totalCalories,
                  target: _target,
                  onTargetChanged: _setTarget,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    "Today's entries",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (state.status == DailyDiaryStatus.error)
                  ErrorView(
                    failure: state.failure as Failure? ??
                        const UnexpectedFailure(),
                    onRetry: () => _dailyDiaryCubit.load(_today),
                  )
                else if (state.entries.isEmpty)
                  const EmptyView(
                    title: 'Nothing logged today',
                    message: 'Tap + to add your first entry.',
                  )
                else
                  ...state.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Dismissible(
                          key: ValueKey(entry.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: Icon(
                              Icons.delete_outline,
                              color: Theme.of(context).colorScheme.onError,
                            ),
                          ),
                          onDismissed: (_) => _deleteEntry(entry),
                          child: DiaryEntryTile(
                            entry: entry,
                            onTap: () => _openEntry(entry: entry),
                            onDelete: () => _deleteEntry(entry),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEntry(date: DateTime.now()),
        tooltip: 'Add entry',
        child: const Icon(Icons.add),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$day';
}
