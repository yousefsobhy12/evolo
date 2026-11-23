import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/dev/debug_seeder.dart';
import 'package:evolo/features/habits/data/repositories/completion_repository_impl.dart';
import 'package:evolo/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/streak_status.dart';
import 'package:evolo/features/habits/domain/usecases/get_streak_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Sunday, so "Morning walk" (Sunday to Thursday) is due today.
  final now = DateTime(2026, 11, 22, 14);
  final today = CalendarDay(2026, 11, 22);

  late AppDatabase database;
  late DebugSeeder seeder;
  late HabitRepositoryImpl habits;
  late CompletionRepositoryImpl completions;

  setUp(() {
    database = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    addTearDown(database.close);
    seeder = DebugSeeder(database, now: () => now);
    habits = HabitRepositoryImpl(database.habitsDao);
    completions = CompletionRepositoryImpl(database.completionsDao);
  });

  Future<List<Habit>> readHabits() async {
    final result = await habits.watchHabits().first;
    return result.getOrElse((_) => fail('expected Right'));
  }

  Future<List<Completion>> readCompletions() async {
    final result = await completions.watchAll().first;
    return result.getOrElse((_) => fail('expected Right'));
  }

  Future<StreakStatus> streakOf(String name) async {
    final habit = (await readHabits()).singleWhere((h) => h.name == name);
    final all = await readCompletions();
    return const GetStreakStatus()(
      habit: habit,
      completions: all.where((c) => c.habitId == habit.id).toList(),
      today: today,
    );
  }

  test('creates five habits, created 30 days ago', () async {
    final made = await seeder.seed(arabic: false);

    expect(made, 5);
    final all = await readHabits();
    expect(
      all.map((h) => h.name),
      unorderedEquals([
        'Drink water',
        'Read',
        'Meditate',
        'Stretch',
        'Morning walk',
      ]),
    );
    for (final habit in all) {
      expect(CalendarDay.fromDateTime(habit.createdAt), today.addDays(-30));
    }
  });

  test('uses Arabic names when asked', () async {
    await seeder.seed(arabic: true);

    final names = (await readHabits()).map((h) => h.name);
    expect(names, contains('شرب الماء'));
    expect(names, isNot(contains('Drink water')));
  });

  test('seeding twice replaces instead of duplicating', () async {
    await seeder.seed(arabic: false);
    await seeder.seed(arabic: false);

    expect(await readHabits(), hasLength(5));
  });

  group('the history tells the story each sample was made for', () {
    setUp(() => seeder.seed(arabic: false));

    test('Drink water: 30 day streak, freezes full, today at risk', () async {
      final streak = await streakOf('Drink water');

      expect(streak.current, 30);
      expect(streak.freezesAvailable, 2);
      expect(streak.isTodayAtRisk, isTrue);
    });

    test('Drink water: today is 3 of 8', () async {
      final habit = (await readHabits()).singleWhere(
        (h) => h.name == 'Drink water',
      );
      final todays = (await readCompletions()).singleWhere(
        (c) => c.habitId == habit.id && c.day == today,
      );

      expect(todays.count, 3);
      expect(todays.target, 8);
    });

    test('Read: a freeze covered the missed day', () async {
      final streak = await streakOf('Read');

      expect(streak.current, 29);
      expect(streak.frozenDays, [today.addDays(-15)]);
    });

    test('Meditate: short streak, done today', () async {
      final streak = await streakOf('Meditate');

      expect(streak.current, 5);
      expect(streak.isTodayAtRisk, isFalse);
    });

    test('Stretch: the streak is broken', () async {
      final streak = await streakOf('Stretch');

      expect(streak.current, 0);
      expect(streak.longest, 11);
    });

    test(
      'Morning walk: only due days are stored, and it keeps a streak',
      () async {
        final habit = (await readHabits()).singleWhere(
          (h) => h.name == 'Morning walk',
        );
        final stored = (await readCompletions()).where(
          (c) => c.habitId == habit.id,
        );
        for (final completion in stored) {
          expect(habit.schedule.isDueOn(completion.day.toDateTime()), isTrue);
        }

        final streak = await streakOf('Morning walk');
        expect(streak.current, 20);
      },
    );
  });

  group('clearAll', () {
    test('removes the habits and, by cascade, their completions', () async {
      await seeder.seed(arabic: false);

      final removed = await seeder.clearAll();

      expect(removed, 5);
      expect(await readHabits(), isEmpty);
      expect(await readCompletions(), isEmpty);
    });

    test('on an empty database it removes nothing', () async {
      expect(await seeder.clearAll(), 0);
    });
  });
}
