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
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  late AppDatabase db;
  late HabitRepositoryImpl habits;
  late CompletionRepositoryImpl repository;
  var idCounter = 0;

  final day1 = CalendarDay(2026, 11, 20);
  final day2 = CalendarDay(2026, 11, 21);

  setUp(() {
    idCounter = 0;
    db = AppDatabase(
      DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    );
    habits = HabitRepositoryImpl(
      db.habitsDao,
      generateId: () => 'h${++idCounter}',
      now: () => DateTime(2026, 11, 20, 9),
    );
    repository = CompletionRepositoryImpl(db.completionsDao);
  });

  tearDown(() => db.close());

  Future<Habit> createHabit({int dailyTarget = 1}) async {
    final result = await habits.createHabit(
      name: 'Read',
      iconKey: 'book',
      color: HabitColor.orange,
      dailyTarget: dailyTarget,
      schedule: HabitSchedule.everyDay(),
    );
    return result.getOrElse((_) => fail('createHabit should succeed'));
  }

  List<Completion> unwrap(Either<Failure, List<Completion>> result) =>
      result.getOrElse((_) => fail('expected Right'));

  Future<List<Completion>> completionsOf(String habitId) async =>
      unwrap(await repository.watchForHabit(habitId).first);

  Future<void> pumpEvents() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('setCount', () {
    test('stores the count with a snapshot of the habit target', () async {
      final habit = await createHabit(dailyTarget: 3);

      final result = await repository.setCount(
        habitId: habit.id,
        day: day1,
        count: 2,
      );

      expect(result, const Right<Failure, Unit>(unit));
      expect(await completionsOf(habit.id), [
        Completion(habitId: habit.id, day: day1, count: 2, target: 3),
      ]);
    });

    test('writing the same day again updates the single row', () async {
      final habit = await createHabit(dailyTarget: 3);

      await repository.setCount(habitId: habit.id, day: day1, count: 1);
      await repository.setCount(habitId: habit.id, day: day1, count: 3);

      final stored = await completionsOf(habit.id);
      expect(stored, hasLength(1));
      expect(stored.single.count, 3);
    });

    test('a later write re-snapshots only the day it touches', () async {
      final habit = await createHabit(dailyTarget: 3);
      await repository.setCount(habitId: habit.id, day: day1, count: 3);

      await habits.updateHabit(habit.copyWith(dailyTarget: 5));
      await repository.setCount(habitId: habit.id, day: day2, count: 1);

      final stored = await completionsOf(habit.id);
      expect(stored.map((c) => c.target), [3, 5]);
    });

    test('count 0 removes the row', () async {
      final habit = await createHabit();
      await repository.setCount(habitId: habit.id, day: day1, count: 1);

      final result = await repository.setCount(
        habitId: habit.id,
        day: day1,
        count: 0,
      );

      expect(result, const Right<Failure, Unit>(unit));
      expect(await completionsOf(habit.id), isEmpty);
    });

    test('count 0 where nothing is stored is a harmless no-op', () async {
      final habit = await createHabit();

      final result = await repository.setCount(
        habitId: habit.id,
        day: day1,
        count: 0,
      );

      expect(result, const Right<Failure, Unit>(unit));
    });

    test('allows more than the target', () async {
      final habit = await createHabit();

      await repository.setCount(habitId: habit.id, day: day1, count: 5);

      expect((await completionsOf(habit.id)).single.count, 5);
    });

    test('rejects a negative count and stores nothing', () async {
      final habit = await createHabit();

      final result = await repository.setCount(
        habitId: habit.id,
        day: day1,
        count: -1,
      );

      expect(
        result,
        const Left<Failure, Unit>(
          ValidationFailure(ValidationReason.negativeCount),
        ),
      );
      expect(await completionsOf(habit.id), isEmpty);
    });

    test('returns NotFoundFailure for an unknown habit', () async {
      final result = await repository.setCount(
        habitId: 'ghost',
        day: day1,
        count: 1,
      );

      expect(result, const Left<Failure, Unit>(NotFoundFailure()));
      expect(await db.select(db.completions).get(), isEmpty);
    });
  });

  group('watchForHabit', () {
    test('returns only that habit, oldest day first', () async {
      final first = await createHabit();
      final second = await createHabit();
      await repository.setCount(habitId: first.id, day: day2, count: 1);
      await repository.setCount(habitId: first.id, day: day1, count: 1);
      await repository.setCount(habitId: second.id, day: day1, count: 1);

      final stored = await completionsOf(first.id);

      expect(stored.map((c) => c.day), [day1, day2]);
    });

    test('emits again after every change', () async {
      final habit = await createHabit();
      final emissions = <int>[];
      final subscription = repository
          .watchForHabit(habit.id)
          .map((result) => unwrap(result).length)
          .listen(emissions.add);
      addTearDown(subscription.cancel);
      await pumpEvents();

      await repository.setCount(habitId: habit.id, day: day1, count: 1);
      await pumpEvents();
      await repository.setCount(habitId: habit.id, day: day2, count: 1);
      await pumpEvents();

      expect(emissions.first, 0);
      expect(emissions.last, 2);
    });

    test('reports a corrupt day as a Left value, not a stream error', () async {
      final habit = await createHabit();
      await db.customStatement(
        'INSERT INTO completions (habit_id, day, count, target) '
        "VALUES ('${habit.id}', 'garbage', 1, 1)",
      );

      final first = await repository.watchForHabit(habit.id).first;

      expect(first, isA<Left<Failure, List<Completion>>>());
    });
  });

  group('watchOnDay', () {
    test(
      'returns every habit on that day and nothing from other days',
      () async {
        final first = await createHabit();
        final second = await createHabit();
        await repository.setCount(habitId: second.id, day: day1, count: 1);
        await repository.setCount(habitId: first.id, day: day1, count: 1);
        await repository.setCount(habitId: first.id, day: day2, count: 1);

        final stored = unwrap(await repository.watchOnDay(day1).first);

        expect(stored.map((c) => c.habitId), [first.id, second.id]);
      },
    );
  });

  group('watchAll', () {
    test('returns every habit, grouped by habit, oldest day first', () async {
      final first = await createHabit();
      final second = await createHabit();
      await repository.setCount(habitId: second.id, day: day1, count: 1);
      await repository.setCount(habitId: first.id, day: day2, count: 1);
      await repository.setCount(habitId: first.id, day: day1, count: 1);

      final stored = unwrap(await repository.watchAll().first);

      expect(stored.map((c) => '${c.habitId} ${c.day}'), [
        '${first.id} $day1',
        '${first.id} $day2',
        '${second.id} $day1',
      ]);
    });

    test('is empty when nothing is stored', () async {
      await createHabit();

      expect(unwrap(await repository.watchAll().first), isEmpty);
    });

    test('emits again after an adjustment', () async {
      final habit = await createHabit();
      final emissions = <int>[];
      final subscription = repository
          .watchAll()
          .map((result) => unwrap(result).length)
          .listen(emissions.add);
      addTearDown(subscription.cancel);
      await pumpEvents();

      await repository.adjustCount(habitId: habit.id, day: day1, delta: 1);
      await pumpEvents();

      expect(emissions.first, 0);
      expect(emissions.last, 1);
    });

    test('reports a corrupt day as a Left value, not a stream error', () async {
      final habit = await createHabit();
      await db.customStatement(
        'INSERT INTO completions (habit_id, day, count, target) '
        "VALUES ('${habit.id}', 'garbage', 1, 1)",
      );

      final first = await repository.watchAll().first;

      expect(first, isA<Left<Failure, List<Completion>>>());
    });
  });

  group('adjustCount', () {
    test('creates the row with a snapshot of the habit target', () async {
      final habit = await createHabit(dailyTarget: 3);

      final result = await repository.adjustCount(
        habitId: habit.id,
        day: day1,
        delta: 1,
      );

      expect(result, const Right<Failure, Unit>(unit));
      expect(await completionsOf(habit.id), [
        Completion(habitId: habit.id, day: day1, count: 1, target: 3),
      ]);
    });

    test('adds to what is already stored', () async {
      final habit = await createHabit(dailyTarget: 8);

      await repository.adjustCount(habitId: habit.id, day: day1, delta: 1);
      await repository.adjustCount(habitId: habit.id, day: day1, delta: 2);

      expect((await completionsOf(habit.id)).single.count, 3);
    });

    test('subtracting back to zero removes the row', () async {
      final habit = await createHabit(dailyTarget: 8);
      await repository.adjustCount(habitId: habit.id, day: day1, delta: 2);

      final result = await repository.adjustCount(
        habitId: habit.id,
        day: day1,
        delta: -2,
      );

      expect(result, const Right<Failure, Unit>(unit));
      expect(await completionsOf(habit.id), isEmpty);
    });

    test('never goes below zero and is not a failure', () async {
      final habit = await createHabit(dailyTarget: 8);

      final onEmptyDay = await repository.adjustCount(
        habitId: habit.id,
        day: day1,
        delta: -1,
      );
      await repository.adjustCount(habitId: habit.id, day: day2, delta: 1);
      final pastZero = await repository.adjustCount(
        habitId: habit.id,
        day: day2,
        delta: -5,
      );

      expect(onEmptyDay, const Right<Failure, Unit>(unit));
      expect(pastZero, const Right<Failure, Unit>(unit));
      expect(await completionsOf(habit.id), isEmpty);
    });

    test(
      'a delta of 0 changes nothing, not even the stored snapshot',
      () async {
        final habit = await createHabit(dailyTarget: 3);
        await repository.adjustCount(habitId: habit.id, day: day1, delta: 2);
        await habits.updateHabit(habit.copyWith(dailyTarget: 5));

        await repository.adjustCount(habitId: habit.id, day: day1, delta: 0);

        expect((await completionsOf(habit.id)).single.target, 3);
      },
    );

    test('re-snapshots the target when the count changes', () async {
      final habit = await createHabit(dailyTarget: 3);
      await repository.adjustCount(habitId: habit.id, day: day1, delta: 2);
      await habits.updateHabit(habit.copyWith(dailyTarget: 5));

      await repository.adjustCount(habitId: habit.id, day: day1, delta: 1);

      final stored = (await completionsOf(habit.id)).single;
      expect(stored.count, 3);
      expect(stored.target, 5);
    });

    test('quick taps are never lost', () async {
      final habit = await createHabit(dailyTarget: 10);

      await Future.wait([
        for (var i = 0; i < 10; i++)
          repository.adjustCount(habitId: habit.id, day: day1, delta: 1),
      ]);

      expect((await completionsOf(habit.id)).single.count, 10);
    });

    test('returns NotFoundFailure for an unknown habit', () async {
      final result = await repository.adjustCount(
        habitId: 'ghost',
        day: day1,
        delta: 1,
      );

      expect(result, const Left<Failure, Unit>(NotFoundFailure()));
      expect(await db.select(db.completions).get(), isEmpty);
    });
  });

  group('deleting a habit', () {
    test('removes its completions and keeps the others', () async {
      final doomed = await createHabit();
      final kept = await createHabit();
      await repository.setCount(habitId: doomed.id, day: day1, count: 1);
      await repository.setCount(habitId: kept.id, day: day1, count: 1);

      await habits.deleteHabit(doomed.id);

      final rows = await db.select(db.completions).get();
      expect(rows.map((row) => row.habitId), [kept.id]);
    });

    test('a watching stream sees the completions disappear', () async {
      final habit = await createHabit();
      await repository.setCount(habitId: habit.id, day: day1, count: 1);
      final emissions = <List<Completion>>[];
      final subscription = repository
          .watchForHabit(habit.id)
          .map(unwrap)
          .listen(emissions.add);
      addTearDown(subscription.cancel);
      await pumpEvents();

      await habits.deleteHabit(habit.id);
      await pumpEvents();

      expect(emissions.first, isNotEmpty);
      expect(emissions.last, isEmpty);
    });
  });

  group('database guards', () {
    test('foreign keys are enforced: no completion for a missing habit', () {
      final insert = db.customStatement(
        'INSERT INTO completions (habit_id, day, count, target) '
        "VALUES ('ghost', '2026-11-20', 1, 1)",
      );

      expect(insert, throwsA(anything));
    });

    test('the database rejects a count below 1', () async {
      final habit = await createHabit();

      final insert = db.customStatement(
        'INSERT INTO completions (habit_id, day, count, target) '
        "VALUES ('${habit.id}', '2026-11-20', 0, 1)",
      );

      await expectLater(insert, throwsA(anything));
    });
  });
}
