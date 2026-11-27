import 'package:equatable/equatable.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';

/// How far one habit got on one day, and whether that day counts as done.
///
/// The single home of the S5 "completed day" rule, shared by the streak, the
/// Today list and the statistics, so they can never disagree.
final class DayProgress extends Equatable {
  const new({required this.count, required this.target});

  /// Judges [day] from its stored row ([completion] is null when there is
  /// none).
  ///
  /// Today is judged by the habit's current `dailyTarget`. A past day is
  /// judged by the snapshot in its row, so changing the goal later does not
  /// rewrite history. A day with no row has no snapshot; its count is 0, so
  /// it is not completed whatever the target is.
  factory of({
    required Habit habit,
    required Completion? completion,
    required CalendarDay day,
    required CalendarDay today,
  }) {
    assert(
      completion == null ||
          (completion.habitId == habit.id && completion.day == day),
      'the completion must belong to this habit and day',
    );
    return DayProgress(
      count: completion?.count ?? 0,
      target: day == today
          ? habit.dailyTarget
          : completion?.target ?? habit.dailyTarget,
    );
  }

  final int count;
  final int target;

  bool get isCompleted => count > 0 && count >= target;

  @override
  List<Object> get props => [count, target];
}
