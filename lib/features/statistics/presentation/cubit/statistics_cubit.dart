import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../diary/domain/usecases/get_entries_for_range.dart';
import '../../domain/usecases/calculate_statistics.dart';
import 'statistics_state.dart';

/// Fetches all diary entries and computes the headline statistics.
///
/// A wide (effectively all-time) date range is read through the diary
/// `GetEntriesForRange` usecase, then [CalculateStatistics] reduces them to
/// the six headline numbers.
class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit({
    required GetEntriesForRange getEntriesForRange,
    required CalculateStatistics calculateStatistics,
    DateTime? now,
  })  : _getEntriesForRange = getEntriesForRange,
        _calculateStatistics = calculateStatistics,
        _now = now,
        super(const StatisticsState());

  final GetEntriesForRange _getEntriesForRange;
  final CalculateStatistics _calculateStatistics;
  final DateTime? _now;

  static const String _allTimeStart = '1970-01-01';
  static const String _allTimeEnd = '2100-12-31';

  Future<void> load() async {
    emit(const StatisticsState(status: StatisticsStatus.loading));
    final result = await _getEntriesForRange(_allTimeStart, _allTimeEnd);
    result.fold(
      (failure) => emit(StatisticsState(
        status: StatisticsStatus.error,
        failure: failure,
      )),
      (entries) => emit(StatisticsState(
        status: StatisticsStatus.loaded,
        statistics: _calculateStatistics(entries, now: _now),
      )),
    );
  }
}
