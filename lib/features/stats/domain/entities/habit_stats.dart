import 'package:equatable/equatable.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/stats/domain/entities/completion_rate.dart';

/// One habit's numbers for a period (one pill bar).
final class HabitStats extends Equatable {
  const new({required this.habit, required this.rate, required this.checkIns});

  final Habit habit;
  final CompletionRate rate;

  /// Days in the period that reached the goal, due or not. A day counts once,
  /// whatever its goal is.
  final int checkIns;

  @override
  List<Object> get props => [habit, rate, checkIns];
}
