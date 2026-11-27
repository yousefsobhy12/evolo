import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/day_progress.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = CalendarDay(2026, 3, 18);
  final yesterday = today.addDays(-1);

  final habit = Habit(
    id: 'h1',
    name: 'Drink water',
    iconKey: 'water',
    color: HabitColor.orange,
    dailyTarget: 8,
    schedule: HabitSchedule.everyDay(),
    createdAt: DateTime(2026, 3, 1, 12),
  );

  // Written when the goal was 3.
  Completion row(CalendarDay day, {required int count}) =>
      Completion(habitId: 'h1', day: day, count: count, target: 3);

  DayProgress progress(CalendarDay day, [Completion? completion]) =>
      DayProgress.of(
        habit: habit,
        completion: completion,
        day: day,
        today: today,
      );

  test('today is judged by the current goal, not the stored one', () {
    final result = progress(today, row(today, count: 3));

    expect(result.target, 8);
    expect(result.isCompleted, isFalse);
  });

  test('a past day is judged by the goal stored in its row', () {
    final result = progress(yesterday, row(yesterday, count: 3));

    expect(result.target, 3);
    expect(result.isCompleted, isTrue);
  });

  test('a day with no row has nothing done', () {
    final result = progress(yesterday);

    expect(result, const DayProgress(count: 0, target: 8));
    expect(result.isCompleted, isFalse);
  });

  test('completed means at least the goal, and more than nothing', () {
    expect(const DayProgress(count: 7, target: 8).isCompleted, isFalse);
    expect(const DayProgress(count: 8, target: 8).isCompleted, isTrue);
    expect(const DayProgress(count: 9, target: 8).isCompleted, isTrue);
    expect(const DayProgress(count: 0, target: 0).isCompleted, isFalse);
  });
}
