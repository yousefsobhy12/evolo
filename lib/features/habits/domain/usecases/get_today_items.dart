import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:evolo/features/habits/domain/usecases/get_streak_status.dart';
import 'package:evolo/features/habits/domain/usecases/is_habit_due.dart';

/// Builds the Today list for one selected day from plain data.
///
/// Pure and synchronous like [GetStreakStatus]: the Cubit feeds it whatever
/// the two streams (habits, completions) emitted last.
///
/// Rules (agreed in S6):
// ignore: comment_references
/// - Only habits due on [day] are listed (`IsHabitDue`, which also hides
///   days before the habit was created). Input order is kept.
// ignore: comment_references
/// - `count` is what is stored for [day], or 0.
/// - `target` follows the S5 rule: today uses the habit's current
///   `dailyTarget`; a past day uses the stored snapshot when it has a row,
///   and the current `dailyTarget` when it has none.
// ignore: comment_references
/// - The streak is always computed as of [today], never as of [day].
// ignore: comment_references
/// - Completions of habits that are not in [habits] are ignored.
final class GetTodayItems {
  const new({
    this._isHabitDue = const IsHabitDue(),
    this._getStreakStatus = const GetStreakStatus(),
  });

  final IsHabitDue _isHabitDue;
  final GetStreakStatus _getStreakStatus;

  List<TodayItem> call({
    required List<Habit> habits,
    required List<Completion> completions,
    required CalendarDay day,
    required CalendarDay today,
  }) {
    assert(!day.isAfter(today), 'The Today list never shows a future day');

    final byHabit = <String, List<Completion>>{};
    for (final completion in completions) {
      byHabit.putIfAbsent(completion.habitId, () => []).add(completion);
    }

    return [
      for (final habit in habits)
        if (_isHabitDue(habit, day))
          _itemFor(
            habit: habit,
            completions: byHabit[habit.id] ?? const <Completion>[],
            day: day,
            today: today,
          ),
    ];
  }

  TodayItem _itemFor({
    required Habit habit,
    required List<Completion> completions,
    required CalendarDay day,
    required CalendarDay today,
  }) {
    final onDay = completions.where((c) => c.day == day).firstOrNull;
    final target = day == today
        ? habit.dailyTarget
        : (onDay?.target ?? habit.dailyTarget);

    return TodayItem(
      habit: habit,
      count: onDay?.count ?? 0,
      target: target,
      streak: _getStreakStatus(
        habit: habit,
        completions: completions,
        today: today,
      ),
    );
  }
}
