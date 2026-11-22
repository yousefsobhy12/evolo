import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/usecases/is_habit_due.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const isHabitDue = IsHabitDue();

  // Created late on Friday 2026-11-20.
  Habit habit(HabitSchedule schedule) => Habit(
    id: 'h1',
    name: 'Read',
    iconKey: 'book',
    color: HabitColor.orange,
    dailyTarget: 1,
    schedule: schedule,
    createdAt: DateTime(2026, 11, 20, 23, 59),
  );

  test('is due on a scheduled weekday after creation', () {
    final fridays = habit(HabitSchedule(const {Weekday.friday}));
    expect(isHabitDue(fridays, CalendarDay(2026, 11, 27)), isTrue);
  });

  test('is not due on a weekday outside the schedule', () {
    final fridays = habit(HabitSchedule(const {Weekday.friday}));
    expect(isHabitDue(fridays, CalendarDay(2026, 11, 28)), isFalse);
  });

  test('is due on the creation day even if created late at night', () {
    final daily = habit(HabitSchedule.everyDay());
    expect(isHabitDue(daily, CalendarDay(2026, 11, 20)), isTrue);
  });

  test('is never due before the habit existed', () {
    final daily = habit(HabitSchedule.everyDay());
    expect(isHabitDue(daily, CalendarDay(2026, 11, 19)), isFalse);
  });
}
