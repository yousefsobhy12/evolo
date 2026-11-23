import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/data/repositories/completion_repository_impl.dart';
import 'package:evolo/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/completion_repository.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';

/// TEMPORARY, debug builds only. Fills the database with 30 days of history
/// so the Today screen can show a streak, freezes, "at risk" and a broken
/// streak without waiting a month.
///
/// It goes through the real repositories (validation included). The only
/// trick is a second [HabitRepositoryImpl] whose clock is set 30 days back,
/// so `createdAt` is in the past and the earlier days count as history.
///
/// Delete with the rest of `lib/dev/` in S14.
class DebugSeeder {
  new(AppDatabase database, {DateTime Function()? now})
    : _now = now ?? DateTime.now,
      _completions = CompletionRepositoryImpl(database.completionsDao),
      _habits = HabitRepositoryImpl(
        database.habitsDao,
        // createdAt = 30 days ago, so the earlier days are real history.
        now: () =>
            CalendarDay.fromDateTime((now ?? DateTime.now)())
                .addDays(-historyDays)
                .toDateTime(),
      );

  /// How far back the habits were "created".
  static const historyDays = 30;

  final DateTime Function() _now;
  final CompletionRepository _completions;
  final HabitRepository _habits;

  CalendarDay get _today => CalendarDay.fromDateTime(_now());

  /// Replaces everything with the sample habits. Returns how many it made.
  Future<int> seed({required bool arabic}) async {
    await clearAll();
    final today = _today;

    for (final scenario in _scenarios) {
      final created = await _habits.createHabit(
        name: arabic ? scenario.nameAr : scenario.nameEn,
        iconKey: scenario.iconKey,
        color: scenario.color,
        dailyTarget: scenario.target,
        schedule: scenario.schedule ?? HabitSchedule.everyDay(),
      );
      final habit = created.fold<Habit>(
        (failure) => throw StateError('Seeding failed: $failure'),
        (habit) => habit,
      );

      for (var offset = -historyDays; offset <= 0; offset++) {
        final day = today.addDays(offset);
        final count = scenario.countOn(offset);
        // A day the habit is not due stays empty, like a real user's data.
        final due = (scenario.schedule ?? HabitSchedule.everyDay()).isDueOn(
          day.toDateTime(),
        );
        if (count == 0 || !due) continue;
        final saved = await _completions.setCount(
          habitId: habit.id,
          day: day,
          count: count,
        );
        saved.fold<void>(
          (failure) => throw StateError('Seeding failed: $failure'),
          (_) {},
        );
      }
    }
    return _scenarios.length;
  }

  /// Deletes every habit (its completions go with it, by the foreign key's
  /// cascade). Returns how many habits there were.
  Future<int> clearAll() async {
    final result = await _habits.watchHabits().first;
    final habits = result.getOrElse((_) => const []);
    for (final habit in habits) {
      await _habits.deleteHabit(habit.id);
    }
    return habits.length;
  }
}

/// One sample habit and the history it should have, as a function of how many
/// days from today (-30 .. 0) it was done. 0 = not done that day.
class _Scenario {
  const new({
    required this.nameEn,
    required this.nameAr,
    required this.iconKey,
    required this.color,
    required this.target,
    required this.countOn,
    this.schedule,
  });

  final String nameEn;
  final String nameAr;
  final String iconKey;
  final HabitColor color;
  final int target;
  final int Function(int offset) countOn;
  final HabitSchedule? schedule;
}

final _scenarios = <_Scenario>[
  // 30 perfect days, today half done: a 30-day streak, 2 freezes (the cap),
  // "at risk", and a progress ring on a counter.
  _Scenario(
    nameEn: 'Drink water',
    nameAr: 'شرب الماء',
    iconKey: 'water',
    color: HabitColor.orange,
    target: 8,
    countOn: (offset) => offset < 0 ? 8 : 3,
  ),
  // One missed day 15 days ago: a freeze covered it, the streak survived.
  _Scenario(
    nameEn: 'Read',
    nameAr: 'القراءة',
    iconKey: 'book',
    color: HabitColor.green,
    target: 1,
    countOn: (offset) => offset == -15 || offset == 0 ? 0 : 1,
  ),
  // Only the last 5 days, today included: a short streak and a done habit.
  _Scenario(
    nameEn: 'Meditate',
    nameAr: 'التأمل',
    iconKey: 'meditate',
    color: HabitColor.pink,
    target: 1,
    countOn: (offset) => offset >= -4 ? 1 : 0,
  ),
  // Stopped 19 days ago: a broken streak (shows "start your streak today").
  _Scenario(
    nameEn: 'Stretch',
    nameAr: 'تمارين الإطالة',
    iconKey: 'yoga',
    color: HabitColor.orange,
    target: 1,
    countOn: (offset) => offset <= -20 ? 1 : 0,
  ),
  // Sunday to Thursday only: on Friday and Saturday it is not in the list.
  _Scenario(
    nameEn: 'Morning walk',
    nameAr: 'المشي الصباحي',
    iconKey: 'walk',
    color: HabitColor.green,
    target: 1,
    countOn: (offset) => offset < 0 ? 1 : 0,
    schedule: HabitSchedule(const {
      Weekday.sunday,
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
      Weekday.thursday,
    }),
  ),
];
