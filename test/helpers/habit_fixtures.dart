import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/entities/streak_status.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';

/// A [TodayItem] for widget tests, with only the fields a test cares about.
TodayItem todayItem({
  String id = 'h1',
  String name = 'Drink water',
  String iconKey = 'water',
  HabitColor color = HabitColor.orange,
  int count = 0,
  int target = 1,
  int streak = 0,
  int freezes = 0,
  bool atRisk = false,
}) {
  return TodayItem(
    habit: Habit(
      id: id,
      name: name,
      iconKey: iconKey,
      color: color,
      dailyTarget: target,
      schedule: HabitSchedule.everyDay(),
      createdAt: DateTime(2026, 3, 1, 12),
    ),
    count: count,
    target: target,
    streak: StreakStatus(
      current: streak,
      longest: streak,
      freezesAvailable: freezes,
      frozenDays: const [],
      isTodayAtRisk: atRisk,
    ),
  );
}
