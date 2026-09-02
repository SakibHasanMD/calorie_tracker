import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/food.dart';
import '../cubit/food_catalog_cubit.dart';
import '../cubit/food_catalog_state.dart';

/// A searchable food picker used by the diary entry form.
///
/// Loads the food catalog via [FoodCatalogCubit], lets the user filter by
/// typing, and reports the selected [Food] through [onSelected].
class FoodPickerField extends StatefulWidget {
  const FoodPickerField({
    super.key,
    required this.onSelected,
    this.initialFoodId,
    this.searchHint = 'Search foods…',
    this.retryLabel = 'Retry',
  });

  final ValueChanged<Food> onSelected;
  final String? initialFoodId;
  final String searchHint;
  final String retryLabel;

  @override
  State<FoodPickerField> createState() => _FoodPickerFieldState();
}

class _FoodPickerFieldState extends State<FoodPickerField> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FoodCatalogCubit, FoodCatalogState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                          context.read<FoodCatalogCubit>().search('');
                        },
                      ),
              ),
              onChanged: (value) {
                setState(() => _query = value);
                context.read<FoodCatalogCubit>().search(value);
              },
            ),
            const SizedBox(height: 8),
            _buildList(context, state),
          ],
        );
      },
    );
  }

  /// Wraps the food-select area in a border so it reads as one scrollable
  /// section (search results, loading, error and empty states alike).
  Widget _bordered(BuildContext context, Widget child) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _buildList(BuildContext context, FoodCatalogState state) {
    switch (state.status) {
      case FoodCatalogStatus.initial:
      case FoodCatalogStatus.loading:
        return _bordered(
          context,
          const SizedBox(height: 140, child: LoadingView()),
        );
      case FoodCatalogStatus.error:
        return _bordered(
          context,
          SizedBox(
            height: 200,
            child: ErrorView(
              failure: state.failure!,
              onRetry: () => context.read<FoodCatalogCubit>().loadFoods(),
            ),
          ),
        );
      case FoodCatalogStatus.loaded:
        final filtered = state.filteredFoods;
        if (filtered.isEmpty) {
          return _bordered(
            context,
            const SizedBox(
              height: 160,
              child: EmptyView(title: 'No foods match'),
            ),
          );
        }

        // Pin the currently-selected food to the top of the list so the user
        // can always see what they picked, even after the widget rebuilds.
        final selectedId = widget.initialFoodId;
        final selectedFirst = selectedId == null
            ? filtered
            : [
                ...filtered.where((f) => f.id == selectedId),
                ...filtered.where((f) => f.id != selectedId),
              ];

        return _bordered(
          context,
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView(
              shrinkWrap: true,
              children: selectedFirst.map((food) {
                final selected = food.id == selectedId;
                final colorScheme = Theme.of(context).colorScheme;
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.restaurant_menu,
                    color: selected ? colorScheme.primary : null,
                  ),
                  title: Text(food.name),
                  subtitle: Text(
                    '${food.category.isEmpty ? 'Uncategorised' : food.category} · '
                    '${food.measurementType == MeasurementType.gram ? '${food.caloriesPerGram?.toStringAsFixed(2) ?? '—'} kcal/g' : '${food.caloriesPerPiece?.toStringAsFixed(0) ?? '—'} kcal/piece'}',
                  ),
                  selected: selected,
                  tileColor: selected
                      ? colorScheme.primary.withValues(alpha: 0.10)
                      : null,
                  trailing: selected
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : null,
                  onTap: () {
                    // Keep the search text and list as-is so the selection
                    // stays visible; the parent reflects it back via
                    // [initialFoodId] on the next rebuild.
                    widget.onSelected(food);
                  },
                );
              }).toList(),
            ),
          ),
        );
    }
  }
}