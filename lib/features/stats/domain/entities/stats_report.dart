import 'package:equatable/equatable.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/stats/domain/entities/completion_rate.dart';
import 'package:evolo/features/stats/domain/entities/habit_stats.dart';
import 'package:evolo/features/stats/domain/entities/stats_period.dart';

/// Everything the statistics screen shows for one period.
final class StatsReport extends Equatable {
  const new({
    required this.period,
    required this.start,
    required this.end,
    required this.habits,
    required this.bestStreak,
  });

  final StatsPeriod period;

  /// First day of the period.
  final CalendarDay start;

  /// Last day included: today.
  final CalendarDay end;

  /// One entry per habit, in the order the habits were given.
  final List<HabitStats> habits;

  /// The longest streak of any habit over **all time**, not just this period.
  final int bestStreak;

  /// All habits together: summed completed days over summed counted days.
  CompletionRate get rate =>
      habits.fold(CompletionRate.empty, (total, stats) => total + stats.rate);

  int get totalCheckIns =>
      habits.fold(0, (total, stats) => total + stats.checkIns);

  @override
  List<Object> get props => [period, start, end, habits, bestStreak];
}
