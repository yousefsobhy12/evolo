import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/data/repositories/completion_repository_impl.dart';
import 'package:evolo/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/usecases/get_streak_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  late AppDatabase db;
  late HabitRepositoryImpl repository;
  late DateTime clock;
  var idCounter = 0;

  setUp(() {
    idCounter = 0;
    clock = DateTime(2026, 11, 20, 9);
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    repository = HabitRepositoryImpl(
      db.habitsDao,
      generateId: () => 'h${++idCounter}',
      now: () => clock,
    );
  });

  tearDown(() => db.close());

  /// Creates a habit and unwraps the `Right`. Fails the test otherwise.
  Future<Habit> createHabit({
    String name = 'Read',
    int dailyTarget = 1,
    HabitSchedule? schedule,
  }) async {
    final result = await repository.createHabit(
      name: name,
      iconKey: 'book',
      color: HabitColor.orange,
      dailyTarget: dailyTarget,
      schedule: schedule ?? HabitSchedule.everyDay(),
    );
    return result.getOrElse((_) => fail('createHabit should succeed'));
  }

  Habit unwrap(Either<Failure, Habit> result) =>
      result.getOrElse((_) => fail('expected Right'));

  List<String> names(Either<Failure, List<Habit>> result) => result
      .getOrElse((_) => fail('expected Right'))
      .map((habit) => habit.name)
      .toList();

  Future<void> pumpEvents() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('createHabit', () {
    test(
      'stores the habit with a generated id, trimmed name, clock time',
      () async {
        final schedule = HabitSchedule(const {Weekday.monday, Weekday.friday});

        final result = await repository.createHabit(
          name: '  Read  ',
          iconKey: 'book',
          color: HabitColor.green,
          dailyTarget: 2,
          schedule: schedule,
        );

        final habit = unwrap(result);
        expect(
          habit,
          Habit(
            id: 'h1',
            name: 'Read',
            iconKey: 'book',
            color: HabitColor.green,
            dailyTarget: 2,
            schedule: schedule,
            createdAt: clock,
          ),
        );
        expect(await repository.getHabit('h1'), Right<Failure, Habit>(habit));
      },
    );

    test('rejects a blank name and stores nothing', () async {
      final result = await repository.createHabit(
        name: '   ',
        iconKey: 'book',
        color: HabitColor.orange,
        dailyTarget: 1,
        schedule: HabitSchedule.everyDay(),
      );

      expect(
        result,
        const Left<Failure, Habit>(
          ValidationFailure(ValidationReason.nameEmpty),
        ),
      );
      expect(await db.select(db.habits).get(), isEmpty);
    });

    test('accepts a 50-character name even with surrounding spaces', () async {
      final habit = await createHabit(name: '  ${'a' * 50}  ');
      expect(habit.name, 'a' * 50);
    });

    test('rejects a 51-character name', () async {
      final result = await repository.createHabit(
        name: 'a' * 51,
        iconKey: 'book',
        color: HabitColor.orange,
        dailyTarget: 1,
        schedule: HabitSchedule.everyDay(),
      );

      expect(
        result,
        const Left<Failure, Habit>(
          ValidationFailure(ValidationReason.nameTooLong),
        ),
      );
    });

    test('rejects a daily target below 1', () async {
      final result = await repository.createHabit(
        name: 'Read',
        iconKey: 'book',
        color: HabitColor.orange,
        dailyTarget: 0,
        schedule: HabitSchedule.everyDay(),
      );

      expect(
        result,
        const Left<Failure, Habit>(
          ValidationFailure(ValidationReason.invalidTarget),
        ),
      );
      expect(await db.select(db.habits).get(), isEmpty);
    });

    test('rejects a daily target above the maximum', () async {
      final result = await repository.createHabit(
        name: 'Read',
        iconKey: 'book',
        color: HabitColor.orange,
        dailyTarget: Habit.maxDailyTarget + 1,
        schedule: HabitSchedule.everyDay(),
      );

      expect(
        result,
        const Left<Failure, Habit>(
          ValidationFailure(ValidationReason.targetTooHigh),
        ),
      );
      expect(await db.select(db.habits).get(), isEmpty);
    });
  });

  group('getHabit', () {
    test('returns NotFoundFailure for an unknown id', () async {
      expect(
        await repository.getHabit('missing'),
        const Left<Failure, Habit>(NotFoundFailure()),
      );
    });

    test(
      'returns DatabaseFailure (does not throw) for a corrupt row',
      () async {
        await db.customStatement(
          'INSERT INTO habits '
          '(id, name, icon_key, color, daily_target, schedule, created_at) '
          "VALUES ('bad', 'Bad', 'book', 'orange', 1, 0, 1)",
        );

        expect(
          await repository.getHabit('bad'),
          const Left<Failure, Habit>(DatabaseFailure()),
        );
      },
    );
  });

  group('updateHabit', () {
    test('changes the editable fields but never id or createdAt', () async {
      final original = await createHabit();
      final tampered = Habit(
        id: original.id,
        name: 'Run',
        iconKey: 'run',
        color: HabitColor.pink,
        dailyTarget: 3,
        schedule: HabitSchedule(const {Weekday.sunday}),
        createdAt: DateTime(2000),
      );

      expect(
        await repository.updateHabit(tampered),
        const Right<Failure, Unit>(unit),
      );

      final stored = unwrap(await repository.getHabit(original.id));
      expect(stored.name, 'Run');
      expect(stored.iconKey, 'run');
      expect(stored.color, HabitColor.pink);
      expect(stored.dailyTarget, 3);
      expect(stored.schedule, HabitSchedule(const {Weekday.sunday}));
      expect(stored.createdAt, original.createdAt);
    });

    test('trims the name', () async {
      final original = await createHabit();

      await repository.updateHabit(original.copyWith(name: '  Walk  '));

      expect(unwrap(await repository.getHabit(original.id)).name, 'Walk');
    });

    test('returns NotFoundFailure for an unknown id', () async {
      final ghost = Habit(
        id: 'ghost',
        name: 'Ghost',
        iconKey: 'book',
        color: HabitColor.orange,
        dailyTarget: 1,
        schedule: HabitSchedule.everyDay(),
        createdAt: clock,
      );

      expect(
        await repository.updateHabit(ghost),
        const Left<Failure, Unit>(NotFoundFailure()),
      );
    });

    test(
      'rejects invalid input and leaves the stored habit untouched',
      () async {
        final original = await createHabit();

        final result = await repository.updateHabit(
          original.copyWith(name: ''),
        );

        expect(
          result,
          const Left<Failure, Unit>(
            ValidationFailure(ValidationReason.nameEmpty),
          ),
        );
        expect(
          await repository.getHabit(original.id),
          Right<Failure, Habit>(original),
        );
      },
    );

    test('rejects a daily target above the maximum', () async {
      final original = await createHabit();

      final result = await repository.updateHabit(
        original.copyWith(dailyTarget: Habit.maxDailyTarget + 1),
      );

      expect(
        result,
        const Left<Failure, Unit>(
          ValidationFailure(ValidationReason.targetTooHigh),
        ),
      );
      expect(
        await repository.getHabit(original.id),
        Right<Failure, Habit>(original),
      );
    });
  });

  // A day is judged by the habit's current target while it is today, and by
  // the stored snapshot once it is past. Editing the target must keep those
  // two views in agreement, or a day the user saw as finished breaks the
  // streak at midnight.
  group('updateHabit and the target snapshot of today', () {
    late CompletionRepositoryImpl completions;
    const getStreakStatus = GetStreakStatus();

    CalendarDay nov(int day) => CalendarDay(2026, 11, day);

    Future<List<Completion>> storedCompletions() async =>
        (await completions.watchAll().first).getOrElse(
          (_) => fail('expected Right'),
        );

    setUp(() => completions = CompletionRepositoryImpl(db.completionsDao));

    test('lowering the target keeps a day that was finished at the new target '
        'finished after midnight', () async {
      final habit = await createHabit(dailyTarget: 5);
      await completions.setCount(habitId: habit.id, day: nov(20), count: 4);

      await repository.updateHabit(habit.copyWith(dailyTarget: 4));

      final stored = (await storedCompletions()).single;
      expect(stored.count, 4);
      expect(stored.target, 4);

      // Next morning the 20th is a past day, judged by its snapshot.
      final streak = getStreakStatus(
        habit: unwrap(await repository.getHabit(habit.id)),
        completions: [stored],
        today: nov(21),
      );
      expect(streak.current, 1);
    });

    test('only today is rewritten, earlier days keep their snapshot', () async {
      clock = DateTime(2026, 11, 18, 9);
      final habit = await createHabit(dailyTarget: 3);
      await completions.setCount(habitId: habit.id, day: nov(19), count: 3);
      await completions.setCount(habitId: habit.id, day: nov(20), count: 2);
      clock = DateTime(2026, 11, 20, 12);

      await repository.updateHabit(habit.copyWith(dailyTarget: 5));

      final byDay = {for (final c in await storedCompletions()) c.day: c};
      expect(byDay[nov(19)]!.target, 3);
      expect(byDay[nov(20)]!.target, 5);
      expect(byDay[nov(20)]!.count, 2);
    });

    test('with no row for today there is nothing to rewrite', () async {
      final habit = await createHabit(dailyTarget: 3);
      await completions.setCount(habitId: habit.id, day: nov(19), count: 3);

      final result = await repository.updateHabit(
        habit.copyWith(dailyTarget: 5),
      );

      expect(result, const Right<Failure, Unit>(unit));
      expect((await storedCompletions()).single.target, 3);
    });

    test('a change that is not the target leaves the snapshot alone', () async {
      final habit = await createHabit(dailyTarget: 3);
      // A snapshot that differs from the habit's target. Only a target
      // change may rewrite it.
      await db
          .into(db.completions)
          .insert(
            CompletionsCompanion.insert(
              habitId: habit.id,
              day: nov(20),
              count: 2,
              target: 9,
            ),
          );

      await repository.updateHabit(habit.copyWith(name: 'Walk'));

      expect((await storedCompletions()).single.target, 9);
    });
  });

  group('deleteHabit', () {
    test('removes the habit', () async {
      final habit = await createHabit();

      expect(
        await repository.deleteHabit(habit.id),
        const Right<Failure, Unit>(unit),
      );
      expect(
        await repository.getHabit(habit.id),
        const Left<Failure, Habit>(NotFoundFailure()),
      );
    });

    test('returns NotFoundFailure for an unknown id', () async {
      expect(
        await repository.deleteHabit('missing'),
        const Left<Failure, Unit>(NotFoundFailure()),
      );
    });
  });

  group('watchHabits', () {
    test('emits the current list and then every change', () async {
      final emissions = <List<String>>[];
      final subscription = repository
          .watchHabits()
          .map(names)
          .listen(emissions.add);
      addTearDown(subscription.cancel);
      await pumpEvents();

      await createHabit();
      await pumpEvents();
      await createHabit(name: 'Run');
      await pumpEvents();

      expect(emissions.first, isEmpty);
      expect(emissions.last, ['Read', 'Run']);
    });

    test('orders habits oldest first', () async {
      clock = DateTime(2026, 11, 20, 10);
      await createHabit(name: 'Late');
      clock = DateTime(2026, 11, 20, 9);
      await createHabit(name: 'Early');

      final list = await repository.watchHabits().first;

      expect(names(list), ['Early', 'Late']);
    });

    test('breaks ties by id when createdAt is the same second', () async {
      await createHabit(name: 'First');
      await createHabit(name: 'Second');

      final list = await repository.watchHabits().first;

      expect(names(list), ['First', 'Second']);
    });

    test('reports a corrupt row as a Left value, not a stream error', () async {
      await db.customStatement(
        'INSERT INTO habits '
        '(id, name, icon_key, color, daily_target, schedule, created_at) '
        "VALUES ('bad', 'Bad', 'book', 'orange', 1, 0, 1)",
      );

      final first = await repository.watchHabits().first;

      expect(first, isA<Left<Failure, List<Habit>>>());
    });
  });
}
