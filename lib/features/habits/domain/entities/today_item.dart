import 'package:equatable/equatable.dart';
import 'package:evolo/features/habits/domain/entities/day_progress.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/streak_status.dart';

/// One row of the Today list: a habit that is due on the selected day, how
/// much of it was done that day, and where its streak stands today.
///
/// It also owns the tap rules, so the Cubit and the widgets contain no
/// counting logic and the rules can be unit-tested on their own.
final class TodayItem extends Equatable {
  const new({
    required this.habit,
    required this.count,
    required this.target,
    required this.streak,
  });

  final Habit habit;

  /// Done on the selected day (0 when nothing is stored).
  final int count;

  /// The goal this day is judged by: the habit's current `dailyTarget` for
  /// today, the stored snapshot for a past day that has a row.
  final int target;

  /// Always as of *today*, whichever day is selected.
  final StreakStatus streak;

  bool get isCompleted => DayProgress(count: count, target: target).isCompleted;

  /// A habit with a goal above 1 (for example "8 glasses"): it shows a
  /// progress ring and a minus button instead of a plain check circle.
  bool get isCounter => target > 1;

  /// Whether the minus button is shown and enabled.
  bool get canDecrement => isCounter && count > 0;

  /// How far the day is from its goal, 0..1 (more than the goal counts as 1).
  /// Drives the progress ring of a counter habit.
  double get progress => (count / target).clamp(0, 1).toDouble();

  /// The streak is worth a warning: there is one to lose and today is still
  /// open. A habit with no streak has nothing at risk, so it shows no warning.
  bool get isStreakAtRisk => streak.isTodayAtRisk && streak.current > 0;

  /// What a tap on the check circle should add to the count (0 = nothing).
  ///
  /// - Goal of 1: toggles. Done => clears the day (even if an older write
  ///   left a count above 1), not done => +1.
  /// - Bigger goal: +1 until the goal is reached, then nothing. Going down
  ///   is the minus button's job, so a tap can never wipe a finished day.
  int get tapDelta {
    if (!isCounter) return isCompleted ? -count : 1;
    return isCompleted ? 0 : 1;
  }

  /// What the minus button adds to the count (0 = nothing).
  int get decrementDelta => canDecrement ? -1 : 0;

  @override
  List<Object> get props => [habit, count, target, streak];
}
