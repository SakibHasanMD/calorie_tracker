import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../diary/domain/usecases/get_entries_for_range.dart';
import '../../../home/data/datasources/calorie_target_local_datasource.dart';
import '../../domain/usecases/calculate_statistics.dart';
import 'statistics_state.dart';

/// Fetches all diary entries and computes the headline statistics.
///
/// A wide (effectively all-time) date range is read through the diary
/// `GetEntriesForRange` usecase, then [CalculateStatistics] reduces them to
/// the numbers + per-period targets.
class StatisticsCubit extends Cubit<StatisticsState> {
  StatisticsCubit({
    required GetEntriesForRange getEntriesForRange,
    required CalculateStatistics calculateStatistics,
    required CalorieTargetLocalDataSource calorieTargetLocalDataSource,
    DateTime? now,
  })  : _getEntriesForRange = getEntriesForRange,
        _calculateStatistics = calculateStatistics,
        _calorieTargetLocalDataSource = calorieTargetLocalDataSource,
        _now = now,
        super(const StatisticsState());

  final GetEntriesForRange _getEntriesForRange;
  final CalculateStatistics _calculateStatistics;
  final CalorieTargetLocalDataSource _calorieTargetLocalDataSource;
  final DateTime? _now;

  static const String _allTimeStart = '1970-01-01';
  static const String _allTimeEnd = '2100-12-31';

  Future<void> load() async {
    emit(const StatisticsState(status: StatisticsStatus.loading));
    final entriesResult =
        await _getEntriesForRange(_allTimeStart, _allTimeEnd);
    // Targets are read independently; if the file is missing the
    // calculator falls back to the default for every day.
    final storedTargets = await _safeReadTargets();
    const defaultTarget = CalorieTargetLocalDataSource.defaultTarget;

    entriesResult.fold(
      (failure) => emit(StatisticsState(
        status: StatisticsStatus.error,
        failure: failure,
      )),
      (entries) => emit(StatisticsState(
        status: StatisticsStatus.loaded,
        statistics: _calculateStatistics(
          entries,
          defaultTarget: defaultTarget,
          storedTargets: storedTargets,
          now: _now,
        ),
      )),
    );
  }

  Future<Map<String, int>> _safeReadTargets() async {
    try {
      return await _calorieTargetLocalDataSource.readAll();
    } catch (_) {
      return const {};
    }
  }
}
