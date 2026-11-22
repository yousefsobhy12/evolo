import 'dart:math';

import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/streak_status.dart';
import 'package:evolo/features/habits/domain/usecases/is_habit_due.dart';

/// Replays a habit's history day by day and returns its streak state.
///
/// Rules (agreed in S5):
/// - Only due days count; other days are neutral.
/// - A due day is done when `count >= target` (the stored snapshot, except
///   today, which uses the habit's current `dailyTarget`).
/// - A past due day that is not done spends a freeze if one is in stock;
///   otherwise it breaks the run. A frozen day bridges the run but adds
///   nothing to it.
/// - Today never breaks the run and never spends a freeze.
/// - Every [daysPerFreeze] completed days in a run earns one freeze, up to
///   [maxFreezes]. Stock starts at 0 and is per habit.
final class GetStreakStatus {
  const new({this._isHabitDue = const IsHabitDue()});

  static const daysPerFreeze = 7;
  static const maxFreezes = 2;

  final IsHabitDue _isHabitDue;

  StreakStatus call({
    required Habit habit,
    required List<Completion> completions,
    required CalendarDay today,
  }) {
    assert(
      completions.every((c) => c.habitId == habit.id),
      'completions must belong to the given habit',
    );
    final byDay = {for (final c in completions) c.day: c};

    var run = 0;
    var longest = 0;
    var freezes = 0;
    var todayAtRisk = false;
    final frozenDays = <CalendarDay>[];

    for (
      var day = CalendarDay.fromDateTime(habit.createdAt);
      !day.isAfter(today);
      day = day.addDays(1)
    ) {
      if (!_isHabitDue(habit, day)) continue;

      final isToday = day == today;
      final completion = byDay[day];
      final target = isToday ? habit.dailyTarget : completion?.target;
      final isDone =
          completion != null &&
          target != null &&
          completion.count > 0 &&
          completion.count >= target;

      if (isDone) {
        run++;
        longest = max(longest, run);
        if (run % daysPerFreeze == 0) {
          freezes = min(freezes + 1, maxFreezes);
        }
      } else if (isToday) {
        todayAtRisk = true;
      } else if (freezes > 0) {
        freezes--;
        frozenDays.add(day);
      } else {
        run = 0;
      }
    }

    return StreakStatus(
      current: run,
      longest: longest,
      freezesAvailable: freezes,
      frozenDays: List.unmodifiable(frozenDays),
      isTodayAtRisk: todayAtRisk,
    );
  }
}
