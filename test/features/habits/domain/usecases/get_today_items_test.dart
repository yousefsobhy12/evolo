import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:evolo/features/habits/domain/usecases/get_today_items.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const getTodayItems = GetTodayItems();

  // Day 1 is Sunday 2026-03-01, so day 2 is a Monday and day 3 a Tuesday.
  final firstDay = CalendarDay(2026, 3, 1);
  CalendarDay day(int n) => firstDay.addDays(n - 1);

  Habit habit({
    String id = 'h1',
    HabitSchedule? schedule,
    int dailyTarget = 1,
    int createdOnDay = 1,
  }) => Habit(
    id: id,
    name: 'Habit $id',
    iconKey: 'book',
    color: HabitColor.orange,
    dailyTarget: dailyTarget,
    schedule: schedule ?? HabitSchedule.everyDay(),
    createdAt: day(createdOnDay).toDateTime(),
  );

  Completion completion(
    String habitId,
    int dayNumber, {
    int count = 1,
    int target = 1,
  }) => Completion(
    habitId: habitId,
    day: day(dayNumber),
    count: count,
    target: target,
  );

  List<TodayItem> items({
    required List<Habit> habits,
    required int selected,
    required int today,
    List<Completion> completions = const [],
  }) => getTodayItems(
    habits: habits,
    completions: completions,
    day: day(selected),
    today: day(today),
  );

  group('which habits are listed', () {
    test('no habits gives an empty list', () {
      expect(items(habits: [], selected: 3, today: 3), isEmpty);
    });

    test('keeps the order it was given', () {
      final result = items(
        habits: [
          habit(id: 'b'),
          habit(id: 'a'),
          habit(id: 'c'),
        ],
        selected: 3,
        today: 3,
      );

      expect(result.map((i) => i.habit.id), ['b', 'a', 'c']);
    });

    test('skips a habit that is not due on the selected day', () {
      final mondayOnly = habit(schedule: HabitSchedule(const {Weekday.monday}));

      expect(items(habits: [mondayOnly], selected: 3, today: 3), isEmpty);
      expect(items(habits: [mondayOnly], selected: 2, today: 3), hasLength(1));
    });

    test('skips days before the habit was created', () {
      final createdOnFive = habit(createdOnDay: 5);

      expect(items(habits: [createdOnFive], selected: 3, today: 6), isEmpty);
      expect(
        items(habits: [createdOnFive], selected: 5, today: 6),
        hasLength(1),
      );
    });
  });

  group('count and target of the selected day', () {
    test('nothing stored gives 0 of the target', () {
      final result = items(
        habits: [habit(dailyTarget: 3)],
        selected: 3,
        today: 3,
      );

      expect(result.single.count, 0);
      expect(result.single.target, 3);
      expect(result.single.isCompleted, isFalse);
    });

    test('today uses the current dailyTarget, not the stored snapshot', () {
      final result = items(
        habits: [habit(dailyTarget: 5)],
        completions: [completion('h1', 3, count: 3, target: 3)],
        selected: 3,
        today: 3,
      );

      expect(result.single.count, 3);
      expect(result.single.target, 5);
      expect(result.single.isCompleted, isFalse);
    });

    test('a past day uses the snapshot stored on its row', () {
      final result = items(
        habits: [habit(dailyTarget: 5)],
        completions: [completion('h1', 3, count: 3, target: 3)],
        selected: 3,
        today: 6,
      );

      expect(result.single.count, 3);
      expect(result.single.target, 3);
      expect(result.single.isCompleted, isTrue);
    });

    test('a past day without a row falls back to the current dailyTarget', () {
      final result = items(
        habits: [habit(dailyTarget: 4)],
        selected: 3,
        today: 6,
      );

      expect(result.single.count, 0);
      expect(result.single.target, 4);
    });

    test('other days of the same habit do not leak into the count', () {
      final result = items(
        habits: [habit()],
        completions: [completion('h1', 2), completion('h1', 4)],
        selected: 3,
        today: 4,
      );

      expect(result.single.count, 0);
    });
  });

  group('streak', () {
    test('is as of today whichever day is selected', () {
      final done = [for (var n = 1; n <= 5; n++) completion('h1', n)];

      final onPastDay = items(
        habits: [habit()],
        completions: done,
        selected: 3,
        today: 6,
      ).single;
      final onToday = items(
        habits: [habit()],
        completions: done,
        selected: 6,
        today: 6,
      ).single;

      expect(onPastDay.count, 1);
      expect(onPastDay.streak.current, 5);
      expect(onPastDay.streak, onToday.streak);
      expect(onToday.streak.isTodayAtRisk, isTrue);
    });

    test('each habit streak is fed only by its own completions', () {
      final result = items(
        habits: [
          habit(),
          habit(id: 'h2'),
        ],
        completions: [for (var n = 1; n <= 3; n++) completion('h1', n)],
        selected: 4,
        today: 4,
      );

      expect(result[0].streak.current, 3);
      expect(result[1].streak.current, 0);
    });

    test('completions of unknown habits are ignored', () {
      final result = items(
        habits: [habit()],
        completions: [completion('ghost', 3)],
        selected: 3,
        today: 3,
      );

      expect(result.single.count, 0);
      expect(result.single.streak.current, 0);
    });
  });

  test('asking for a future day is a programming error', () {
    expect(
      () => items(habits: [habit()], selected: 7, today: 6),
      throwsA(isA<AssertionError>()),
    );
  });
}
