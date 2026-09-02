import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/food.dart';

/// Status of the [FoodCatalogCubit].
enum FoodCatalogStatus { initial, loading, loaded, error }

/// Single state class for the food catalog.
class FoodCatalogState extends Equatable {
  const FoodCatalogState({
    this.status = FoodCatalogStatus.initial,
    this.foods = const [],
    this.query = '',
    this.failure,
  });

  final FoodCatalogStatus status;
  final List<Food> foods;

  /// The active search filter applied to [foods].
  final String query;

  /// Present only when [status] is [FoodCatalogStatus.error].
  final Failure? failure;

  /// Foods after applying the active [query] filter.
  List<Food> get filteredFoods {
    if (query.trim().isEmpty) return foods;
    final q = query.trim().toLowerCase();
    return foods
        .where((f) =>
            f.name.toLowerCase().contains(q) ||
            f.category.toLowerCase().contains(q))
        .toList();
  }

  FoodCatalogState copyWith({
    FoodCatalogStatus? status,
    List<Food>? foods,
    String? query,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return FoodCatalogState(
      status: status ?? this.status,
      foods: foods ?? this.foods,
      query: query ?? this.query,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, foods, query, failure];
}