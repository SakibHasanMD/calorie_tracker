import 'package:fpdart/fpdart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/food.dart';
import '../../domain/usecases/add_custom_food.dart';
import '../../domain/usecases/delete_custom_food.dart';
import '../../domain/usecases/get_all_foods.dart';
import '../../domain/usecases/update_custom_food.dart';
import 'food_catalog_state.dart';

/// Manages the food catalog: loading, searching, and custom-food CRUD.
///
/// Keeps the full loaded list in state and derives the filtered list via
/// [FoodCatalogState.filteredFoods], so search never re-fetches.
class FoodCatalogCubit extends Cubit<FoodCatalogState> {
  FoodCatalogCubit({
    required GetAllFoods getAllFoods,
    required AddCustomFood addCustomFood,
    required UpdateCustomFood updateCustomFood,
    required DeleteCustomFood deleteCustomFood,
  })  : _getAllFoods = getAllFoods,
        _addCustomFood = addCustomFood,
        _updateCustomFood = updateCustomFood,
        _deleteCustomFood = deleteCustomFood,
        super(const FoodCatalogState());

  final GetAllFoods _getAllFoods;
  final AddCustomFood _addCustomFood;
  final UpdateCustomFood _updateCustomFood;
  final DeleteCustomFood _deleteCustomFood;

  Future<void> loadFoods() async {
    emit(const FoodCatalogState(status: FoodCatalogStatus.loading));
    final result = await _getAllFoods();
    result.fold(
      (failure) =>
          emit(FoodCatalogState(status: FoodCatalogStatus.error, failure: failure)),
      (foods) =>
          emit(FoodCatalogState(status: FoodCatalogStatus.loaded, foods: foods)),
    );
  }

  void search(String query) {
    final current = state;
    if (current.status != FoodCatalogStatus.loaded) return;
    emit(current.copyWith(query: query));
  }

  Future<void> addCustom(Food food) async {
    final result = await _addCustomFood(food);
    _applySaveMutation(result);
  }

  Future<void> updateCustom(Food food) async {
    final result = await _updateCustomFood(food);
    _applySaveMutation(result);
  }

  Future<void> deleteCustom(String id) async {
    final result = await _deleteCustomFood(id);
    result.fold(
      (failure) => emit(
        state.copyWith(status: FoodCatalogStatus.error, failure: failure),
      ),
      (_) {
        final foods = state.foods.where((f) => f.id != id).toList();
        emit(state.copyWith(status: FoodCatalogStatus.loaded, foods: foods));
      },
    );
  }

  /// Applies a successful add/update to the loaded list, or surfaces failure.
  void _applySaveMutation(Either<Failure, Food> result) {
    result.fold(
      (failure) => emit(
        state.copyWith(status: FoodCatalogStatus.error, failure: failure),
      ),
      (updated) {
        final foods = [...state.foods];
        final index = foods.indexWhere((f) => f.id == updated.id);
        if (index == -1) {
          foods.add(updated);
        } else {
          foods[index] = updated;
        }
        emit(state.copyWith(status: FoodCatalogStatus.loaded, foods: foods));
      },
    );
  }
}