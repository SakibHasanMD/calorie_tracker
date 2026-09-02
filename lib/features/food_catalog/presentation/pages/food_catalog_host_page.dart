import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/widgets/loading_view.dart';
import '../cubit/food_catalog_cubit.dart';
import '../cubit/food_catalog_state.dart';
import 'manage_foods_page.dart';

/// Track 2 integration: the Home tab.
///
/// Hosts the [FoodCatalogCubit] for the rest of the app and exposes a
/// manage-foods action in the app bar. Track 4 will replace the body with
/// the real daily diary view; for now we just show the cubit's loaded state
/// so the wiring (BlocProvider, DI, JSON round-trip) is proven end-to-end.
class FoodCatalogHostPage extends StatelessWidget {
  const FoodCatalogHostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FoodCatalogCubit>(
      create: (_) => Injector.getIt<FoodCatalogCubit>()..loadFoods(),
      child: const _FoodCatalogHomeView(),
    );
  }
}

class _FoodCatalogHomeView extends StatelessWidget {
  const _FoodCatalogHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            tooltip: 'Manage foods',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BlocProvider.value(
                    value: context.read<FoodCatalogCubit>(),
                    child: const ManageFoodsPage(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<FoodCatalogCubit, FoodCatalogState>(
        builder: (context, state) {
          switch (state.status) {
            case FoodCatalogStatus.initial:
            case FoodCatalogStatus.loading:
              return const LoadingView(message: 'Loading…');
            case FoodCatalogStatus.error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load: ${state.failure?.message ?? 'unknown'}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            case FoodCatalogStatus.loaded:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department, size: 56),
                      const SizedBox(height: 8),
                      Text(
                        '${state.foods.length} foods available',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track 4 will replace this with your daily diary.',
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
