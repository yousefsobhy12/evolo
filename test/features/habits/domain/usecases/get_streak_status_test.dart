import 'dart:math';

import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/entities/streak_status.dart';
import 'package:evolo/features/habits/domain/usecases/get_streak_status.dart';
import 'package:evolo/features/habits/domain/usecases/is_habit_due.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const getStreakStatus = GetStreakStatus();

  // Day 1 is Sunday 2026-03-01, so day 2 is a Monday and day 20 a Friday.
  final firstDay = CalendarDay(2026, 3, 1);
  CalendarDay day(int n) => firstDay.addDays(n - 1);

  Iterable<int> span(int from, int to) => [for (var n = from; n <= to; n++) n];

  Habit habit({
    HabitSchedule? schedule,
    int dailyTarget = 1,
    int createdOnDay = 1,
  }) => Habit(
    id: 'h1',
    name: 'Read',
    iconKey: 'book',
    color: HabitColor.orange,
    dailyTarget: dailyTarget,
    schedule: schedule ?? HabitSchedule.everyDay(),
    createdAt: day(createdOnDay).toDateTime(),
  );

  List<Completion> done(Iterable<int> days, {int count = 1, int target = 1}) =>
      [
        for (final n in days)
          Completion(habitId: 'h1', day: day(n), count: count, target: target),
      ];

  StreakStatus status({
    required int today,
    List<Completion> completions = const [],
    Habit? forHabit,
  }) => getStreakStatus(
    habit: forHabit ?? habit(),
    completions: completions,
    today: day(today),
  );

  group('basics', () {
    test('a new habit with nothing done has no streak and is at risk', () {
      final result = status(today: 1);

      expect(result.current, 0);
      expect(result.longest, 0);
      expect(result.freezesAvailable, 0);
      expect(result.frozenDays, isEmpty);
      expect(result.isTodayAtRisk, isTrue);
    });

    test('counts consecutive completed days', () {
      final result = status(today: 5, completions: done(span(1, 5)));

      expect(result.current, 5);
      expect(result.longest, 5);
      expect(result.isTodayAtRisk, isFalse);
    });

    test('a pending today does not break the run and is flagged', () {
      final result = status(today: 6, completions: done(span(1, 5)));

      expect(result.current, 5);
      expect(result.isTodayAtRisk, isTrue);
    });

    test('a missed day breaks the run but longest remembers it', () {
      final result = status(
        today: 8,
        completions: [
          ...done(span(1, 5)),
          ...done([7, 8]),
        ],
      );

      expect(result.current, 2);
      expect(result.longest, 5);
    });

    test('a partial day below its target counts as missed', () {
      final result = status(
        today: 5,
        completions: [
          ...done(span(1, 3)),
          ...done([4], target: 2),
        ],
      );

      expect(result.current, 0);
      expect(result.longest, 3);
      expect(result.isTodayAtRisk, isTrue);
    });

    test('doing more than the target still counts as one done day', () {
      final result = status(today: 1, completions: done([1], count: 5));

      expect(result.current, 1);
    });

    test('a habit created after today yields the empty status', () {
      final result = status(today: 5, forHabit: habit(createdOnDay: 10));

      expect(result, StreakStatus.empty);
    });

    test('rejects completions that belong to another habit', () {
      final foreign = [
        Completion(habitId: 'other', day: day(1), count: 1, target: 1),
      ];

      expect(
        () => status(today: 1, completions: foreign),
        throwsAssertionError,
      );
    });
  });

  group('which days count', () {
    test('days before the habit was created are ignored', () {
      final result = status(
        today: 4,
        forHabit: habit(createdOnDay: 3),
        completions: done(span(1, 4)),
      );

      expect(result.current, 2);
      expect(result.longest, 2);
    });

    test('streak units are due days: Mon/Wed/Fri for 3 weeks is 9', () {
      final mwf = habit(
        schedule: HabitSchedule(const {
          Weekday.monday,
          Weekday.wednesday,
          Weekday.friday,
        }),
        createdOnDay: 2,
      );
      final completions = done(const [2, 4, 6, 9, 11, 13, 16, 18, 20]);

      final onFriday = status(
        today: 20,
        forHabit: mwf,
        completions: completions,
      );
      final onSaturday = status(
        today: 21,
        forHabit: mwf,
        completions: completions,
      );

      expect(onFriday.current, 9);
      expect(onFriday.longest, 9);
      expect(onSaturday.current, 9);
      expect(onSaturday.isTodayAtRisk, isFalse);
    });

    test('a completion on a non-due day does not count', () {
      final mondays = habit(schedule: HabitSchedule(const {Weekday.monday}));

      final result = status(
        today: 3,
        forHabit: mondays,
        completions: done([2, 3]),
      );

      expect(result.current, 1);
      expect(result.isTodayAtRisk, isFalse);
    });

    test('completions after today are ignored', () {
      final result = status(today: 3, completions: done([1, 2, 3, 10]));

      expect(result.current, 3);
      expect(result.longest, 3);
    });

    test('a schedule applies to the whole history (known S5 limitation)', () {
      // Same completions (Mon/Wed/Fri), judged by two different schedules.
      final completions = done([2, 4, 6]);
      final mwf = habit(
        schedule: HabitSchedule(const {
          Weekday.monday,
          Weekday.wednesday,
          Weekday.friday,
        }),
        createdOnDay: 2,
      );
      final daily = habit(createdOnDay: 2);

      final underMwf = status(
        today: 6,
        forHabit: mwf,
        completions: completions,
      );
      final underDaily = status(
        today: 6,
        forHabit: daily,
        completions: completions,
      );

      expect(underMwf.current, 3);
      expect(underDaily.current, 1);
    });
  });

  group('target snapshot', () {
    test('past days keep the target they were written with', () {
      final raisedTarget = habit(dailyTarget: 2);

      final result = status(
        today: 6,
        forHabit: raisedTarget,
        completions: done(span(1, 5)),
      );

      expect(result.current, 5);
      expect(result.isTodayAtRisk, isTrue);
    });

    test('today is judged by the habit current target', () {
      final needsTwo = habit(dailyTarget: 2);

      final once = status(
        today: 6,
        forHabit: needsTwo,
        completions: [
          ...done(span(1, 5)),
          ...done([6]),
        ],
      );
      final twice = status(
        today: 6,
        forHabit: needsTwo,
        completions: [
          ...done(span(1, 5)),
          ...done([6], count: 2),
        ],
      );

      expect(once.current, 5);
      expect(once.isTodayAtRisk, isTrue);
      expect(twice.current, 6);
      expect(twice.isTodayAtRisk, isFalse);
    });
  });

  group('streak freeze', () {
    test('is earned after 7 completed days, not before', () {
      expect(
        status(today: 6, completions: done(span(1, 6))).freezesAvailable,
        0,
      );
      expect(
        status(today: 7, completions: done(span(1, 7))).freezesAvailable,
        1,
      );
    });

    test('covers one missed day and keeps the run (worked example)', () {
      final result = status(
        today: 11,
        completions: done([...span(1, 7), 9, 11]),
      );

      expect(
        result,
        StreakStatus(
          current: 1,
          longest: 8,
          freezesAvailable: 0,
          frozenDays: [day(8)],
          isTodayAtRisk: false,
        ),
      );
    });

    test('a frozen day bridges the run but adds nothing to it', () {
      final result = status(today: 9, completions: done([...span(1, 7), 9]));

      expect(result.current, 8);
      expect(result.frozenDays, [day(8)]);
    });

    test('a frozen day does not count toward the next freeze', () {
      final completions = done([...span(1, 7), ...span(9, 14)]);

      final onDay14 = status(today: 14, completions: completions);
      final onDay15 = status(
        today: 15,
        completions: done([...span(1, 7), ...span(9, 15)]),
      );

      expect(onDay14.current, 13);
      expect(onDay14.freezesAvailable, 0);
      expect(onDay15.current, 14);
      expect(onDay15.freezesAvailable, 1);
    });

    test('stock is capped at two', () {
      final result = status(today: 21, completions: done(span(1, 21)));

      expect(result.current, 21);
      expect(result.freezesAvailable, 2);
    });

    test('two missed days in a row are covered by two freezes', () {
      final result = status(today: 17, completions: done(span(1, 14)));

      expect(result.current, 14);
      expect(result.freezesAvailable, 0);
      expect(result.frozenDays, [day(15), day(16)]);
      expect(result.isTodayAtRisk, isTrue);
    });

    test('a third missed day in a row breaks the run', () {
      final result = status(today: 18, completions: done(span(1, 14)));

      expect(result.current, 0);
      expect(result.longest, 14);
      expect(result.frozenDays, [day(15), day(16)]);
    });

    test('today never spends a freeze', () {
      final result = status(today: 8, completions: done(span(1, 7)));

      expect(result.current, 7);
      expect(result.freezesAvailable, 1);
      expect(result.frozenDays, isEmpty);
      expect(result.isTodayAtRisk, isTrue);
    });

    test('a break restarts the milestone counter', () {
      final result = status(
        today: 11,
        completions: done([...span(1, 3), ...span(5, 11)]),
      );

      expect(result.current, 7);
      expect(result.longest, 7);
      expect(result.freezesAvailable, 1);
    });
  });

  group('invariants on random histories', () {
    test('hold for 300 generated habits', () {
      final random = Random(42);
      const isHabitDue = IsHabitDue();

      for (var round = 0; round < 300; round++) {
        final weekdays = [...Weekday.values]..shuffle(random);
        final target = 1 + random.nextInt(3);
        final subject = habit(
          schedule: HabitSchedule(weekdays.take(1 + random.nextInt(7)).toSet()),
          dailyTarget: target,
        );
        final span = 1 + random.nextInt(60);
        final completions = [
          for (var n = 1; n <= span; n++)
            if (random.nextDouble() < 0.65)
              Completion(
                habitId: 'h1',
                day: day(n),
                count: 1 + random.nextInt(4),
                target: 1 + random.nextInt(3),
              ),
        ];

        final result = getStreakStatus(
          habit: subject,
          completions: completions,
          today: day(span),
        );

        expect(result.freezesAvailable, inInclusiveRange(0, 2));
        expect(result.current, greaterThanOrEqualTo(0));
        expect(result.longest, greaterThanOrEqualTo(result.current));
        for (final frozen in result.frozenDays) {
          expect(isHabitDue(subject, frozen), isTrue);
          expect(frozen.isBefore(day(span)), isTrue);
        }
        final todayRow = completions.where((c) => c.day == day(span));
        final doneToday =
            todayRow.isNotEmpty && todayRow.single.count >= target;
        expect(
          result.isTodayAtRisk,
          isHabitDue(subject, day(span)) && !doneToday,
        );
      }
    });
  });
}
