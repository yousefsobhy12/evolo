import 'dart:math';

import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/day_progress.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/usecases/get_streak_status.dart';
import 'package:evolo/features/habits/domain/usecases/get_week_days.dart';
import 'package:evolo/features/habits/domain/usecases/is_habit_due.dart';
import 'package:evolo/features/stats/domain/entities/completion_rate.dart';
import 'package:evolo/features/stats/domain/entities/habit_stats.dart';
import 'package:evolo/features/stats/domain/entities/stats_period.dart';
import 'package:evolo/features/stats/domain/entities/stats_report.dart';

/// Builds the statistics of the current week or month from plain data.
///
/// Pure and synchronous, like `GetStreakStatus`. Rules (agreed in S8):
/// - The period starts on the first day of the week or of the month and ends
///   today. Days before a habit was created are ignored.
/// - Rate: only due days count. A past due day that is not completed counts
///   against it, including a day a streak freeze covered.
/// - Today counts only once it is completed (in both numbers or in neither).
/// - Check-ins: every day that reached its goal, due or not.
/// - A completed day is whatever [DayProgress] says it is.
/// - The current schedule applies to the whole history.
final class GetHabitStats {
  const new({
    this._isHabitDue = const IsHabitDue(),
    this._getStreakStatus = const GetStreakStatus(),
    this._getWeekDays = const GetWeekDays(),
  });

  final IsHabitDue _isHabitDue;
  final GetStreakStatus _getStreakStatus;
  final GetWeekDays _getWeekDays;

  StatsReport call({
    required List<Habit> habits,
    required List<Completion> completions,
    required StatsPeriod period,
    required CalendarDay today,
    required Weekday firstDay,
  }) {
    final start = switch (period) {
      StatsPeriod.week => _getWeekDays(day: today, firstDay: firstDay).first,
      StatsPeriod.month => CalendarDay(today.year, today.month, 1),
    };

    final byHabit = <String, List<Completion>>{};
    for (final completion in completions) {
      byHabit.putIfAbsent(completion.habitId, () => []).add(completion);
    }

    final stats = <HabitStats>[];
    var bestStreak = 0;
    for (final habit in habits) {
      final own = byHabit[habit.id] ?? const <Completion>[];
      stats.add(
        _statsFor(habit: habit, completions: own, start: start, today: today),
      );
      final streak = _getStreakStatus(
        habit: habit,
        completions: own,
        today: today,
      );
      bestStreak = max(bestStreak, streak.longest);
    }

    return StatsReport(
      period: period,
      start: start,
      end: today,
      habits: List.unmodifiable(stats),
      bestStreak: bestStreak,
    );
  }

  HabitStats _statsFor({
    required Habit habit,
    required List<Completion> completions,
    required CalendarDay start,
    required CalendarDay today,
  }) {
    final byDay = {for (final c in completions) c.day: c};
    final createdOn = CalendarDay.fromDateTime(habit.createdAt);

    var completedDays = 0;
    var dueDays = 0;
    var checkIns = 0;

    for (
      var day = createdOn.isAfter(start) ? createdOn : start;
      !day.isAfter(today);
      day = day.addDays(1)
    ) {
      final isCompleted = DayProgress.of(
        habit: habit,
        completion: byDay[day],
        day: day,
        today: today,
      ).isCompleted;
      if (isCompleted) checkIns++;

      if (!_isHabitDue(habit, day)) continue;
      // An open today is not a miss yet.
      if (day == today && !isCompleted) continue;
      dueDays++;
      if (isCompleted) completedDays++;
    }

    return HabitStats(
      habit: habit,
      rate: CompletionRate(completedDays: completedDays, dueDays: dueDays),
      checkIns: checkIns,
    );
  }
}
