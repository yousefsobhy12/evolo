import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/entities/streak_status.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final habit = Habit(
    id: 'h1',
    name: 'Water',
    iconKey: 'water',
    color: HabitColor.orange,
    dailyTarget: 1,
    schedule: HabitSchedule.everyDay(),
    createdAt: DateTime(2026, 3, 1, 12),
  );

  TodayItem item({required int count, required int target}) => TodayItem(
    habit: habit,
    count: count,
    target: target,
    streak: StreakStatus.empty,
  );

  group('isCompleted', () {
    test('is false while the count is below the target', () {
      expect(item(count: 0, target: 1).isCompleted, isFalse);
      expect(item(count: 7, target: 8).isCompleted, isFalse);
    });

    test('is true at the target and above it', () {
      expect(item(count: 1, target: 1).isCompleted, isTrue);
      expect(item(count: 8, target: 8).isCompleted, isTrue);
      expect(item(count: 9, target: 8).isCompleted, isTrue);
    });
  });

  group('a habit with a goal of 1', () {
    test('is not a counter and has no minus button', () {
      expect(item(count: 1, target: 1).isCounter, isFalse);
      expect(item(count: 1, target: 1).canDecrement, isFalse);
      expect(item(count: 1, target: 1).decrementDelta, 0);
    });

    test('a tap checks it off', () {
      expect(item(count: 0, target: 1).tapDelta, 1);
    });

    test('a tap on a done day clears it', () {
      expect(item(count: 1, target: 1).tapDelta, -1);
    });

    test('a tap clears the whole count even if it is above 1', () {
      // An older write (or a lowered goal) can leave count 3 on a goal of 1.
      expect(item(count: 3, target: 1).tapDelta, -3);
    });
  });

  group('a habit with a goal above 1', () {
    test('is a counter', () {
      expect(item(count: 0, target: 8).isCounter, isTrue);
    });

    test('a tap adds one until the goal is reached', () {
      expect(item(count: 0, target: 8).tapDelta, 1);
      expect(item(count: 7, target: 8).tapDelta, 1);
    });

    test('a tap does nothing once the goal is reached or passed', () {
      expect(item(count: 8, target: 8).tapDelta, 0);
      expect(item(count: 9, target: 8).tapDelta, 0);
    });

    test('the minus button is off at 0 and removes one otherwise', () {
      expect(item(count: 0, target: 8).canDecrement, isFalse);
      expect(item(count: 0, target: 8).decrementDelta, 0);
      expect(item(count: 3, target: 8).canDecrement, isTrue);
      expect(item(count: 3, target: 8).decrementDelta, -1);
    });

    test('the minus button still works on a finished or exceeded day', () {
      expect(item(count: 8, target: 8).decrementDelta, -1);
      expect(item(count: 9, target: 8).decrementDelta, -1);
    });
  });

  group('progress', () {
    test('is the share of the goal that is done', () {
      expect(item(count: 0, target: 8).progress, 0);
      expect(item(count: 2, target: 8).progress, 0.25);
      expect(item(count: 1, target: 1).progress, 1);
    });

    test('never goes above 1, even past the goal', () {
      expect(item(count: 9, target: 8).progress, 1);
      expect(item(count: 3, target: 1).progress, 1);
    });
  });

  group('isStreakAtRisk', () {
    TodayItem withStreak({required int current, required bool atRisk}) =>
        TodayItem(
          habit: habit,
          count: 0,
          target: 1,
          streak: StreakStatus(
            current: current,
            longest: current,
            freezesAvailable: 0,
            frozenDays: const [],
            isTodayAtRisk: atRisk,
          ),
        );

    test('is true when a streak exists and today is still open', () {
      expect(withStreak(current: 5, atRisk: true).isStreakAtRisk, isTrue);
    });

    test('is false when today is already done', () {
      expect(withStreak(current: 5, atRisk: false).isStreakAtRisk, isFalse);
    });

    test('is false when there is no streak to lose', () {
      expect(withStreak(current: 0, atRisk: true).isStreakAtRisk, isFalse);
    });
  });
}
