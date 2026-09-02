import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/food.dart';
import '../cubit/food_catalog_cubit.dart';
import '../cubit/food_catalog_state.dart';
import '../widgets/food_list_tile.dart';

/// Manage foods: view the seeded catalog and add/edit/delete custom foods.
///
/// Seeded foods are shown but not editable/deletable here; only user-added
/// (`isCustom`) foods support edit/delete.
class ManageFoodsPage extends StatelessWidget {
  const ManageFoodsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Foods')),
      body: BlocBuilder<FoodCatalogCubit, FoodCatalogState>(
        builder: (context, state) {
          return _buildBody(context, state);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openFoodForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add food'),
      ),
    );
  }

  Widget _buildBody(BuildContext context, FoodCatalogState state) {
    switch (state.status) {
      case FoodCatalogStatus.initial:
      case FoodCatalogStatus.loading:
        return const LoadingView(message: 'Loading foods…');
      case FoodCatalogStatus.error:
        return ErrorView(
          failure: state.failure!,
          onRetry: () => context.read<FoodCatalogCubit>().loadFoods(),
        );
      case FoodCatalogStatus.loaded:
        final foods = state.foods;
        if (foods.isEmpty) {
          return const EmptyView(
            title: 'No foods yet',
            message: 'Add your first custom food using the button below.',
          );
        }
        final custom = foods.where((f) => f.isCustom).toSet();
        return ListView(
          children: [
            const _SectionHeader('Catalog'),
            ...foods
                .where((f) => !f.isCustom)
                .map((f) => FoodListTile(food: f)),
            if (custom.isNotEmpty) const _SectionHeader('Custom foods'),
            ...custom.map(
              (f) => FoodListTile(
                food: f,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                      onPressed: () => _openFoodForm(context, food: f),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(context, f),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        );
    }
  }

  void _openFoodForm(BuildContext context, {Food? food}) {
    showDialog<void>(
      context: context,
      builder: (_) => _FoodFormDialog(
        existing: food,
        onSave: (name, category, type, perGram, perPiece) {
          if (food == null) {
            context.read<FoodCatalogCubit>().addCustom(
                  Food(
                    id: '',
                    name: name,
                    category: category,
                    measurementType: type,
                    caloriesPerGram: type == MeasurementType.gram ? perGram : null,
                    caloriesPerPiece:
                        type == MeasurementType.piece ? perPiece : null,
                  ),
                );
          } else {
            context.read<FoodCatalogCubit>().updateCustom(
                  food.copyWith(
                    name: name,
                    category: category,
                    measurementType: type,
                    caloriesPerGram:
                        type == MeasurementType.gram ? perGram : null,
                    clearCaloriesPerGram: type != MeasurementType.gram,
                    caloriesPerPiece:
                        type == MeasurementType.piece ? perPiece : null,
                    clearCaloriesPerPiece: type != MeasurementType.piece,
                  ),
                );
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Food food) async {
    final cubit = context.read<FoodCatalogCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete food'),
        content: Text('Delete "${food.name}" from your custom foods?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      cubit.deleteCustom(food.id);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _FoodFormDialog extends StatefulWidget {
  const _FoodFormDialog({required this.onSave, this.existing});

  final Food? existing;
  final void Function(
    String name,
    String category,
    MeasurementType type,
    double perGram,
    double perPiece,
  ) onSave;

  @override
  State<_FoodFormDialog> createState() => _FoodFormDialogState();
}

class _FoodFormDialogState extends State<_FoodFormDialog> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _perGramController = TextEditingController();
  final _perPieceController = TextEditingController();
  late MeasurementType _type;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.measurementType ?? MeasurementType.gram;
    if (existing != null) {
      _nameController.text = existing.name;
      _categoryController.text = existing.category;
      _perGramController.text =
          existing.caloriesPerGram?.toString() ?? '';
      _perPieceController.text =
          existing.caloriesPerPiece?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _perGramController.dispose();
    _perPieceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add food' : 'Edit food'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<MeasurementType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Measured by', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(
                    value: MeasurementType.gram, child: Text('Per gram (g)')),
                DropdownMenuItem(
                    value: MeasurementType.piece, child: Text('Per piece')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _type = value);
              },
            ),
            const SizedBox(height: 12),
            if (_type == MeasurementType.gram)
              TextField(
                controller: _perGramController,
                decoration: const InputDecoration(
                    labelText: 'Calories per gram *', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              )
            else
              TextField(
                controller: _perPieceController,
                decoration: const InputDecoration(
                    labelText: 'Calories per piece *', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _save() {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Food name is required.')),
      );
      return;
    }
    double? perGram;
    double? perPiece;
    if (_type == MeasurementType.gram) {
      perGram = double.tryParse(_perGramController.text.trim());
      if (perGram == null || perGram <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter calories per gram.')),
        );
        return;
      }
    } else {
      perPiece = double.tryParse(_perPieceController.text.trim());
      if (perPiece == null || perPiece <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter calories per piece.')),
        );
        return;
      }
    }
    widget.onSave(name, category, _type, perGram ?? 0, perPiece ?? 0);
    Navigator.of(context).pop();
  }
}