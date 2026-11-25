import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HabitSchedule', () {
    test('equality ignores insertion order', () {
      expect(
        HabitSchedule(const {Weekday.monday, Weekday.friday}),
        HabitSchedule(const {Weekday.friday, Weekday.monday}),
      );
    });

    test('different days are not equal', () {
      expect(
        HabitSchedule(const {Weekday.monday}),
        isNot(HabitSchedule(const {Weekday.tuesday})),
      );
    });

    test('everyDay has seven days and isEveryDay', () {
      final schedule = HabitSchedule.everyDay();
      expect(schedule.days, hasLength(7));
      expect(schedule.isEveryDay, isTrue);
    });

    test('isDueOn matches the weekday', () {
      final friday = DateTime(2026, 11, 20); // a Friday
      final saturday = DateTime(2026, 11, 21);
      final schedule = HabitSchedule(const {Weekday.friday});

      expect(schedule.isDueOn(friday), isTrue);
      expect(schedule.isDueOn(saturday), isFalse);
    });

    test('an empty schedule is rejected', () {
      expect(() => HabitSchedule(const {}), throwsAssertionError);
    });

    test('days cannot be mutated from outside', () {
      final schedule = HabitSchedule(const {Weekday.monday});
      expect(() => schedule.days.add(Weekday.tuesday), throwsUnsupportedError);
    });
  });

  group('Habit', () {
    final habit = Habit(
      id: 'h1',
      name: 'Read',
      iconKey: 'book',
      color: HabitColor.orange,
      dailyTarget: 1,
      schedule: HabitSchedule.everyDay(),
      createdAt: DateTime(2026, 11, 20),
    );

    test('equal habits are equal', () {
      expect(habit.copyWith(), habit);
    });

    test('each field takes part in equality', () {
      expect(habit.copyWith(name: 'Run'), isNot(habit));
      expect(habit.copyWith(iconKey: 'run'), isNot(habit));
      expect(habit.copyWith(color: HabitColor.green), isNot(habit));
      expect(habit.copyWith(dailyTarget: 2), isNot(habit));
      expect(
        habit.copyWith(schedule: HabitSchedule(const {Weekday.monday})),
        isNot(habit),
      );
    });

    test('copyWith keeps id and createdAt', () {
      final copy = habit.copyWith(name: 'Run');
      expect(copy.id, habit.id);
      expect(copy.createdAt, habit.createdAt);
    });
  });

  group('Habit.validate', () {
    ValidationReason? validate({String name = 'Read', int dailyTarget = 1}) {
      return Habit.validate(
        name: name,
        dailyTarget: dailyTarget,
        schedule: HabitSchedule.everyDay(),
      );
    }

    test('accepts the smallest and the largest daily target', () {
      expect(validate(), isNull);
      expect(validate(dailyTarget: Habit.maxDailyTarget), isNull);
    });

    test('rejects a daily target below 1', () {
      expect(validate(dailyTarget: 0), ValidationReason.invalidTarget);
      expect(validate(dailyTarget: -3), ValidationReason.invalidTarget);
    });

    test('rejects a daily target above the maximum', () {
      expect(
        validate(dailyTarget: Habit.maxDailyTarget + 1),
        ValidationReason.targetTooHigh,
      );
    });

    test('reports the first problem: name, then target, then days', () {
      expect(
        Habit.validate(
          name: ' ',
          dailyTarget: 0,
          schedule: HabitSchedule.everyDay(),
        ),
        ValidationReason.nameEmpty,
      );
      expect(
        Habit.validate(
          name: 'Read',
          dailyTarget: 0,
          schedule: HabitSchedule.everyDay(),
        ),
        ValidationReason.invalidTarget,
      );
    });
  });

  // The form shows each field's error on its own, with the same rules.
  group('per-field rules', () {
    test('nameLength ignores surrounding spaces and counts an emoji as 2', () {
      expect(Habit.nameLength('  Read  '), 4);
      expect(Habit.nameLength('💧'), 2);
      expect(Habit.nameLength('   '), 0);
    });

    test('validateName accepts 1 to 50 characters', () {
      expect(Habit.validateName('a'), isNull);
      expect(Habit.validateName('a' * Habit.maxNameLength), isNull);
      expect(Habit.validateName(''), ValidationReason.nameEmpty);
      expect(Habit.validateName('  '), ValidationReason.nameEmpty);
      expect(
        Habit.validateName('a' * (Habit.maxNameLength + 1)),
        ValidationReason.nameTooLong,
      );
    });

    test('validateDailyTarget accepts the min and max, nothing outside', () {
      expect(Habit.validateDailyTarget(Habit.minDailyTarget), isNull);
      expect(Habit.validateDailyTarget(Habit.maxDailyTarget), isNull);
      expect(
        Habit.validateDailyTarget(Habit.minDailyTarget - 1),
        ValidationReason.invalidTarget,
      );
      expect(
        Habit.validateDailyTarget(Habit.maxDailyTarget + 1),
        ValidationReason.targetTooHigh,
      );
    });

    test('validateDays needs at least one day', () {
      expect(Habit.validateDays({Weekday.monday}), isNull);
      expect(Habit.validateDays({}), ValidationReason.noDaysSelected);
    });
  });
}
