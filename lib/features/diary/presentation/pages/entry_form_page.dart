import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../food_catalog/domain/entities/food.dart';
import '../../../food_catalog/domain/usecases/get_all_foods.dart';
import '../../../food_catalog/presentation/cubit/food_catalog_cubit.dart';
import '../../../food_catalog/presentation/cubit/food_catalog_state.dart';
import '../../../food_catalog/presentation/widgets/food_picker_field.dart';
import '../../domain/entities/diary_entry.dart';
import '../../domain/usecases/add_diary_entry.dart';
import '../../domain/usecases/get_recent_foods.dart';
import '../../domain/usecases/update_diary_entry.dart';
import '../cubit/daily_diary_cubit.dart';
import '../cubit/diary_form_cubit.dart';
import '../cubit/diary_form_state.dart';
import '../widgets/recent_foods_row.dart';

/// Single shared page for add and edit.
///
/// - No date/entry → add for today.
/// - `date` only → add for that date.
/// - `existingEntry` → edit that entry (and `date` is ignored; the original
///   entry's date is preserved unless the user changes it).
class EntryFormPage extends StatelessWidget {
  const EntryFormPage({
    super.key,
    this.date,
    this.existingEntry,
    required this.dailyDiaryCubit,
  });

  final DateTime? date;
  final DiaryEntry? existingEntry;
  final DailyDiaryCubit dailyDiaryCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DiaryFormCubit>(
      create: (_) => DiaryFormCubit(
        addEntry: Injector.getIt<AddDiaryEntry>(),
        updateEntry: Injector.getIt<UpdateDiaryEntry>(),
        editing: existingEntry,
      ),
      child: _EntryFormView(
        date: date,
        dailyDiaryCubit: dailyDiaryCubit,
        existingEntry: existingEntry,
      ),
    );
  }
}

class _EntryFormView extends StatefulWidget {
  const _EntryFormView({
    required this.date,
    required this.dailyDiaryCubit,
    this.existingEntry,
  });

  final DateTime? date;
  final DailyDiaryCubit dailyDiaryCubit;
  final DiaryEntry? existingEntry;

  @override
  State<_EntryFormView> createState() => _EntryFormViewState();
}

class _EntryFormViewState extends State<_EntryFormView> {
  late final TextEditingController _amountController;
  List<DiaryEntry> _recentFoods = const [];
  bool _loadingRecent = true;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<DiaryFormCubit>();
    // In add mode the cubit defaults to today; if the page was opened for a
    // specific date, use that date so the user doesn't have to re-pick it.
    // (Edit mode ignores [widget.date] — the entry's own date is preserved.)
    if (widget.date != null && cubit.state.editingEntryId == null) {
      cubit.changeDate(widget.date!);
    }
    _amountController = TextEditingController(
      text: cubit.state.amount > 0 ? cubit.state.amount.toString() : '',
    );
    _loadRecent();
  }

  Future<void> _loadRecent() async {
    final result = await Injector.getIt<GetRecentFoods>().call(limit: 5);
    if (!mounted) return;
    setState(() {
      _recentFoods = result.fold((_) => const [], (list) => list);
      _loadingRecent = false;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiaryFormCubit, DiaryFormState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) async {
        if (state.status == DiaryFormStatus.saved) {
          await widget.dailyDiaryCubit.load(
            state.entryDate!.toIso8601String().substring(0, 10),
          );
          if (context.mounted) Navigator.of(context).pop();
        } else if (state.status == DiaryFormStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Could not save entry'),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.existingEntry == null ? 'Add entry' : 'Edit entry',
          ),
        ),
        body: BlocBuilder<DiaryFormCubit, DiaryFormState>(
          builder: (context, state) {
            final cubit = context.read<DiaryFormCubit>();
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Food', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                _FoodSelectionField(
                  initialFood: state.food,
                  onChanged: cubit.selectFood,
                ),
                if (!_loadingRecent && _recentFoods.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Recent',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  RecentFoodsRow(
                    entries: _recentFoods,
                    onPick: (entry) async {
                      final foodsResult =
                          await Injector.getIt<GetAllFoods>().call();
                      final foods = foodsResult.fold(
                        (_) => <Food>[],
                        (l) => l,
                      );
                      final match = foods
                          .where((f) => f.id == entry.foodId)
                          .cast<Food?>()
                          .firstWhere((_) => true, orElse: () => null);
                      if (match == null) return;
                      cubit.selectFood(match);
                      _amountController.text = entry.amount.toString();
                      cubit.changeAmount(entry.amount);
                    },
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    suffixText: state.food?.measurementType.unitLabel,
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v.trim()) ?? 0;
                    cubit.changeAmount(parsed);
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                      state.entryDate == null
                          ? '—'
                          : state.entryDate!.toIso8601String().substring(0, 10),
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.entryDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) cubit.changeDate(picked);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department),
                        const SizedBox(width: 8),
                        Text(
                          'Total: ${state.calories.toStringAsFixed(0)} kcal',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: state.status == DiaryFormStatus.submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                  onPressed: state.status == DiaryFormStatus.submitting
                      ? null
                      : cubit.submit,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Wraps the shared [FoodPickerField] inside its own [FoodCatalogCubit]
/// provider so the picker can search/filter foods independently of any
/// parent widget tree.
class _FoodSelectionField extends StatefulWidget {
  const _FoodSelectionField({this.initialFood, required this.onChanged});

  final Food? initialFood;
  final ValueChanged<Food> onChanged;

  @override
  State<_FoodSelectionField> createState() => _FoodSelectionFieldState();
}

class _FoodSelectionFieldState extends State<_FoodSelectionField> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<FoodCatalogCubit>(
      create: (_) => Injector.getIt<FoodCatalogCubit>()..loadFoods(),
      child: _FoodPickerContent(
        initialFood: widget.initialFood,
        onFoodSelected: widget.onChanged,
      ),
    );
  }
}

class _FoodPickerContent extends StatelessWidget {
  const _FoodPickerContent({
    required this.initialFood,
    required this.onFoodSelected,
  });

  final Food? initialFood;
  final ValueChanged<Food> onFoodSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodCatalogCubit, FoodCatalogState>(
      builder: (context, state) {
        if (state.status == FoodCatalogStatus.initial ||
            state.status == FoodCatalogStatus.loading) {
          return const LoadingView(message: 'Loading foods…');
        }
        if (state.status == FoodCatalogStatus.error) {
          return Text(
            'Failed to load foods: ${state.failure?.message ?? 'unknown'}',
          );
        }
        return FoodPickerField(
          initialFoodId: initialFood?.id,
          onSelected: (food) => onFoodSelected(food),
        );
      },
    );
  }
}
