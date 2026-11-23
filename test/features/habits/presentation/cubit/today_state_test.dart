import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/entities/streak_status.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 2026-11-22 is a Sunday.
  final today = CalendarDay(2026, 11, 22);
  CalendarDay nov(int day) => CalendarDay(2026, 11, day);

  TodayState state({
    CalendarDay? selected,
    Weekday weekStart = Weekday.saturday,
    CalendarDay? first,
    TodayStatus status = TodayStatus.success,
    List<TodayItem> items = const [],
    bool hasAnyHabit = false,
  }) => TodayState(
    today: today,
    selectedDay: selected ?? today,
    weekStart: weekStart,
    firstSelectableDay: first,
    status: status,
    items: items,
    hasAnyHabit: hasAnyHabit,
  );

  group('days', () {
    test('are the seven days of the selected week, Saturday first', () {
      final days = state().days;

      expect(days.map((d) => d.day), [for (var i = 21; i <= 27; i++) nov(i)]);
    });

    test('follow the configured first weekday', () {
      final days = state(weekStart: Weekday.sunday).days;

      expect(days.first.day, nov(22));
      expect(days.last.day, nov(28));
    });

    test('flag the selected day and today', () {
      final days = state(selected: nov(21)).days;

      expect(days.where((d) => d.isSelected).single.day, nov(21));
      expect(days.where((d) => d.isToday).single.day, today);
    });

    test('future days are not selectable', () {
      final days = state().days;

      expect(days.map((d) => d.isSelectable), [
        true,
        true,
        false,
        false,
        false,
        false,
        false,
      ]);
    });

    test('days before the first selectable day are not selectable', () {
      final days = state(first: nov(22)).days;

      expect(days.first.day, nov(21));
      expect(days.first.isSelectable, isFalse);
      expect(days[1].isSelectable, isTrue);
    });
  });

  group('canGoPrevious', () {
    test('is false while the first selectable day is unknown', () {
      expect(state().canGoPrevious, isFalse);
    });

    test('is true when earlier days exist before this week', () {
      expect(state(first: nov(1)).canGoPrevious, isTrue);
    });

    test('is false when the first selectable day is inside this week', () {
      expect(state(first: nov(22)).canGoPrevious, isFalse);
      expect(state(first: nov(21)).canGoPrevious, isFalse);
    });
  });

  group('canGoNext', () {
    test('is false in the week of today', () {
      expect(state().canGoNext, isFalse);
      expect(state(selected: nov(21)).canGoNext, isFalse);
    });

    test('is true in a past week', () {
      expect(state(selected: nov(20)).canGoNext, isTrue);
      expect(state(selected: nov(15)).canGoNext, isTrue);
    });
  });

  group('emptyReason', () {
    final item = TodayItem(
      habit: Habit(
        id: 'h1',
        name: 'Read',
        iconKey: 'book',
        color: HabitColor.orange,
        dailyTarget: 1,
        schedule: HabitSchedule.everyDay(),
        createdAt: DateTime(2026, 11, 1, 9),
      ),
      count: 0,
      target: 1,
      streak: StreakStatus.empty,
    );

    test('is null while loading or after a failure', () {
      expect(state(status: TodayStatus.loading).emptyReason, isNull);
      expect(state(status: TodayStatus.failure).emptyReason, isNull);
    });

    test('is noHabits when no habit exists', () {
      expect(state().emptyReason, TodayEmptyReason.noHabits);
    });

    test('is nothingDue when habits exist but none is due', () {
      expect(state(hasAnyHabit: true).emptyReason, TodayEmptyReason.nothingDue);
    });

    test('is null when there is something to list', () {
      expect(state(items: [item], hasAnyHabit: true).emptyReason, isNull);
    });
  });

  test('two states with the same data are equal', () {
    expect(state(first: nov(1)), state(first: nov(1)));
    expect(state(first: nov(1)), isNot(state(first: nov(2))));
    expect(
      TodayState(
        today: today,
        selectedDay: today,
        weekStart: Weekday.saturday,
        status: TodayStatus.failure,
        failure: const DatabaseFailure(),
      ),
      TodayState(
        today: today,
        selectedDay: today,
        weekStart: Weekday.saturday,
        status: TodayStatus.failure,
        failure: const DatabaseFailure(),
      ),
    );
  });
}
