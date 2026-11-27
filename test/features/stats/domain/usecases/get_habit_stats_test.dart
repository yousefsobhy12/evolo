import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/stats/domain/entities/completion_rate.dart';
import 'package:evolo/features/stats/domain/entities/stats_period.dart';
import 'package:evolo/features/stats/domain/entities/stats_report.dart';
import 'package:evolo/features/stats/domain/usecases/get_habit_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const getHabitStats = GetHabitStats();

  // Day 1 is Sunday 2026-03-01, so day 14 is a Saturday and day 18 a
  // Wednesday. Day 32 is April 1st.
  final firstOfMarch = CalendarDay(2026, 3, 1);
  CalendarDay day(int n) => firstOfMarch.addDays(n - 1);

  List<int> span(int from, int to) => [for (var n = from; n <= to; n++) n];

  Habit habit({
    String id = 'h1',
    Set<Weekday>? days,
    int dailyTarget = 1,
    int createdOnDay = 1,
  }) => Habit(
    id: id,
    name: 'Habit $id',
    iconKey: 'book',
    color: HabitColor.orange,
    dailyTarget: dailyTarget,
    schedule: days == null ? HabitSchedule.everyDay() : HabitSchedule(days),
    createdAt: day(createdOnDay).toDateTime(),
  );

  List<Completion> done(
    List<int> days, {
    String id = 'h1',
    int count = 1,
    int target = 1,
  }) => [
    for (final n in days)
      Completion(habitId: id, day: day(n), count: count, target: target),
  ];

  StatsReport report({
    required int today,
    List<Habit>? habits,
    List<Completion> completions = const [],
    StatsPeriod period = StatsPeriod.week,
    Weekday firstDay = Weekday.saturday,
  }) => getHabitStats(
    habits: habits ?? [habit()],
    completions: completions,
    period: period,
    today: day(today),
    firstDay: firstDay,
  );

  CompletionRate rate(int completed, int due) =>
      CompletionRate(completedDays: completed, dueDays: due);

  group('period', () {
    test('a week starts on the given weekday and ends today', () {
      final result = report(today: 18);

      expect(result.period, StatsPeriod.week);
      expect(result.start, day(14));
      expect(result.end, day(18));
    });

    test('another first weekday moves the start', () {
      final result = report(today: 18, firstDay: Weekday.sunday);

      expect(result.start, day(15));
    });

    test('a month starts on the 1st', () {
      final result = report(today: 18, period: StatsPeriod.month);

      expect(result.start, day(1));
      expect(result.end, day(18));
    });

    test('a week can start in the previous month, a month cannot', () {
      final completions = done(span(28, 33));

      final week = report(today: 33, completions: completions);
      final month = report(
        today: 33,
        completions: completions,
        period: StatsPeriod.month,
      );

      expect(week.start, day(28));
      expect(week.totalCheckIns, 6);
      expect(month.start, day(32));
      expect(month.totalCheckIns, 2);
    });

    test('completions before the period are not counted', () {
      final result = report(today: 18, completions: done(span(1, 18)));

      expect(result.rate, rate(5, 5));
      expect(result.totalCheckIns, 5);
    });

    test('completions after today are ignored', () {
      final result = report(today: 16, completions: done([14, 15, 17]));

      expect(result.rate, rate(2, 2));
      expect(result.totalCheckIns, 2);
    });
  });

  group('completion rate', () {
    test('an open today is in neither number', () {
      final result = report(today: 18, completions: done(span(14, 17)));

      expect(result.rate, rate(4, 4));
    });

    test('a completed today is in both numbers', () {
      final result = report(today: 18, completions: done(span(14, 18)));

      expect(result.rate, rate(5, 5));
    });

    test('a past day with no row is a miss, and the percent rounds down', () {
      final result = report(today: 17, completions: done([14, 16]));

      expect(result.rate, rate(2, 3));
      expect(result.rate.percent, 66);
    });

    test('a partly done day is not completed', () {
      final result = report(
        today: 16,
        habits: [habit(dailyTarget: 8)],
        completions: [
          ...done([14], count: 7, target: 8),
          ...done([15], count: 8, target: 8),
        ],
      );

      expect(result.rate, rate(1, 2));
      expect(result.totalCheckIns, 1);
    });

    test('past days use their stored goal, today uses the current one', () {
      // The goal was 3, then it was raised to 8.
      final result = report(
        today: 15,
        habits: [habit(dailyTarget: 8)],
        completions: done([14, 15], count: 3, target: 3),
      );

      expect(result.rate, rate(1, 1));
      expect(result.totalCheckIns, 1);
    });

    test('a day covered by a freeze counts against the rate', () {
      // 7 completed days earn a freeze, which covers day 8.
      final result = report(
        today: 10,
        period: StatsPeriod.month,
        completions: done([...span(1, 7), 9, 10]),
      );

      expect(result.rate, rate(9, 10));
      expect(result.bestStreak, 9);
    });

    test('days before the habit was created are ignored', () {
      final result = report(
        today: 18,
        habits: [habit(createdOnDay: 16)],
        completions: done(span(14, 17)),
      );

      expect(result.rate, rate(2, 2));
      expect(result.totalCheckIns, 2);
    });

    test('a habit created today and still open has no percent', () {
      final result = report(today: 18, habits: [habit(createdOnDay: 18)]);

      expect(result.rate, CompletionRate.empty);
      expect(result.rate.percent, isNull);
    });

    test('an open first day of the week has no percent', () {
      final result = report(today: 14, completions: done(span(1, 13)));

      expect(result.rate.percent, isNull);
    });

    test('the current schedule applies to past days too', () {
      final completions = done([14, 16]);

      final daily = report(today: 17, completions: completions);
      final twoDays = report(
        today: 17,
        habits: [
          habit(days: {Weekday.saturday, Weekday.monday}),
        ],
        completions: completions,
      );

      expect(daily.rate, rate(2, 3));
      expect(twoDays.rate, rate(2, 2));
    });
  });

  group('check-ins', () {
    test('a day off adds a check-in but does not touch the rate', () {
      // Due on Sunday (15) and Monday (16). Saturday (14) is a day off.
      final result = report(
        today: 17,
        habits: [
          habit(days: {Weekday.sunday, Weekday.monday}),
        ],
        completions: done([14, 15]),
      );

      expect(result.rate, rate(1, 2));
      expect(result.totalCheckIns, 2);
    });

    test('a completed today that is a day off is a check-in only', () {
      final result = report(
        today: 18,
        habits: [
          habit(days: {Weekday.sunday}),
        ],
        completions: done([18]),
      );

      expect(result.rate, rate(0, 1));
      expect(result.totalCheckIns, 1);
    });

    test('a partly done day off is not a check-in', () {
      final result = report(
        today: 17,
        habits: [
          habit(days: {Weekday.sunday}, dailyTarget: 8),
        ],
        completions: done([14], count: 3, target: 8),
      );

      expect(result.totalCheckIns, 0);
    });

    test('a goal of 8 reached is one check-in', () {
      final result = report(
        today: 14,
        habits: [habit(dailyTarget: 8)],
        completions: done([14], count: 8, target: 8),
      );

      expect(result.totalCheckIns, 1);
    });
  });

  group('all habits', () {
    test('the total sums the days instead of averaging percentages', () {
      // h1: 1 of 1 (100%). h2: 1 of 4 (25%). The average would be 62%.
      final result = report(
        today: 18,
        habits: [
          habit(createdOnDay: 17),
          habit(id: 'h2'),
        ],
        completions: [
          ...done([17]),
          ...done([14], id: 'h2'),
        ],
      );

      expect(result.habits[0].rate, rate(1, 1));
      expect(result.habits[1].rate, rate(1, 4));
      expect(result.rate, rate(2, 5));
      expect(result.rate.percent, 40);
      expect(result.totalCheckIns, 2);
    });

    test('keeps the order of the habits, with or without data', () {
      final result = report(
        today: 18,
        habits: [
          habit(id: 'b'),
          habit(id: 'a', createdOnDay: 18),
        ],
      );

      expect([for (final s in result.habits) s.habit.id], ['b', 'a']);
    });

    test('best streak is the longest of any habit over all time', () {
      // h1 had its 5 days before this week.
      final result = report(
        today: 18,
        habits: [
          habit(),
          habit(id: 'h2'),
        ],
        completions: [
          ...done(span(1, 5)),
          ...done([16, 17], id: 'h2'),
        ],
      );

      expect(result.bestStreak, 5);
    });

    test('completions of unknown habits are ignored', () {
      final result = report(today: 18, completions: done([17], id: 'gone'));

      expect(result.totalCheckIns, 0);
      expect(result.bestStreak, 0);
    });

    test('no habits gives an empty report', () {
      final result = report(today: 18, habits: const []);

      expect(result.habits, isEmpty);
      expect(result.rate.percent, isNull);
      expect(result.totalCheckIns, 0);
      expect(result.bestStreak, 0);
    });
  });
}
