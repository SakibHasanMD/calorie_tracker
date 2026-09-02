import 'package:equatable/equatable.dart';

import '../../domain/entities/calendar_summary.dart';

enum HistoryStatus { initial, loading, loaded, error }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.period = CalendarPeriod.month,
    this.referenceDate,
    this.summary,
    this.failure,
  });

  final HistoryStatus status;
  final CalendarPeriod period;
  final DateTime? referenceDate;
  final CalendarSummary? summary;
  final Object? failure;

  HistoryState copyWith({
    HistoryStatus? status,
    CalendarPeriod? period,
    DateTime? referenceDate,
    CalendarSummary? summary,
    Object? failure,
    bool clearFailure = false,
    bool clearSummary = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      period: period ?? this.period,
      referenceDate: referenceDate ?? this.referenceDate,
      summary: clearSummary ? null : (summary ?? this.summary),
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, period, referenceDate, summary, failure];
}
