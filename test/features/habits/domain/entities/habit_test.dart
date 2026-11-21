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
}
