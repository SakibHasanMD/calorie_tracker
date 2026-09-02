import 'package:equatable/equatable.dart';

import '../../domain/entities/statistics.dart';

enum StatisticsStatus { initial, loading, loaded, error }

class StatisticsState extends Equatable {
  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.statistics,
    this.failure,
  });

  final StatisticsStatus status;
  final Statistics? statistics;
  final Object? failure;

  StatisticsState copyWith({
    StatisticsStatus? status,
    Statistics? statistics,
    Object? failure,
    bool clearFailure = false,
  }) {
    return StatisticsState(
      status: status ?? this.status,
      statistics: statistics ?? this.statistics,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, statistics, failure];
}
