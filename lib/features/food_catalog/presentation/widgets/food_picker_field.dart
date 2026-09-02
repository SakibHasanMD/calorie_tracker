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

  Widget _buildList(BuildContext context, FoodCatalogState state) {
    switch (state.status) {
      case FoodCatalogStatus.initial:
      case FoodCatalogStatus.loading:
        return const SizedBox(height: 120, child: LoadingView());
      case FoodCatalogStatus.error:
        return SizedBox(
          height: 120,
          child: ErrorView(
            failure: state.failure!,
            onRetry: () => context.read<FoodCatalogCubit>().loadFoods(),
          ),
        );
      case FoodCatalogStatus.loaded:
        final foods = state.filteredFoods;
        if (foods.isEmpty) {
          return const SizedBox(
            height: 120,
            child: EmptyView(title: 'No foods match'),
          );
        }
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 260),
          child: ListView(
            shrinkWrap: true,
            children: foods.map((food) {
              final selected = food.id == widget.initialFoodId;
              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.restaurant_menu,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(food.name),
                subtitle: Text(
                  food.measurementType == MeasurementType.gram
                      ? '${food.caloriesPerGram?.toStringAsFixed(2) ?? '—'} kcal/g'
                      : '${food.caloriesPerPiece?.toStringAsFixed(0) ?? '—'} kcal/piece',
                ),
                selected: selected,
                onTap: () {
                  widget.onSelected(food);
                  setState(() => _query = '');
                  _searchController.clear();
                  context.read<FoodCatalogCubit>().search('');
                },
              );
            }).toList(),
          ),
        );
    }
  }
}