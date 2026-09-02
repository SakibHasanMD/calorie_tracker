import 'package:equatable/equatable.dart';

import '../../domain/entities/diary_entry.dart';

enum DailyDiaryStatus { initial, loading, loaded, error }

class DailyDiaryState extends Equatable {
  const DailyDiaryState({
    this.status = DailyDiaryStatus.initial,
    this.date = '',
    this.entries = const [],
    this.totalCalories = 0,
    this.failure,
  });

  final DailyDiaryStatus status;

  /// The `YYYY-MM-DD` string this state represents.
  final String date;

  final List<DiaryEntry> entries;

  final double totalCalories;

  final Object? failure;

  DailyDiaryState copyWith({
    DailyDiaryStatus? status,
    String? date,
    List<DiaryEntry>? entries,
    double? totalCalories,
    Object? failure,
    bool clearFailure = false,
  }) {
    return DailyDiaryState(
      status: status ?? this.status,
      date: date ?? this.date,
      entries: entries ?? this.entries,
      totalCalories: totalCalories ?? this.totalCalories,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, date, entries, totalCalories, failure];
}
