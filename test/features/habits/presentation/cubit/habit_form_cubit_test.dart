import 'dart:async';

import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository;

void main() {
  // The habit used by every edit-mode test.
  final stored = Habit(
    id: 'h1',
    name: 'Read',
    iconKey: 'book',
    color: HabitColor.green,
    dailyTarget: 2,
    schedule: HabitSchedule(const {Weekday.monday, Weekday.friday}),
    createdAt: DateTime(2026, 11, 1, 9),
  );

  late MockHabitRepository repository;

  setUpAll(() {
    registerFallbackValue(HabitColor.orange);
    registerFallbackValue(HabitSchedule.everyDay());
    registerFallbackValue(stored);
  });

  setUp(() => repository = MockHabitRepository());

  /// Lets the Cubit's pending futures finish.
  Future<void> pump() async {
    for (var i = 0; i < 20; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  // `any()` calls have to run inside when() / verify(), hence the closure.
  Future<Either<Failure, Habit>> anyCreate() => repository.createHabit(
    name: any(named: 'name'),
    iconKey: any(named: 'iconKey'),
    color: any(named: 'color'),
    dailyTarget: any(named: 'dailyTarget'),
    schedule: any(named: 'schedule'),
  );

  void stubCreate(Either<Failure, Habit> result) =>
      when(anyCreate).thenAnswer((_) async => result);

  void stubUpdate(Either<Failure, Unit> result) =>
      when(() => repository.updateHabit(any())).thenAnswer((_) async => result);

  void stubDelete(Either<Failure, Unit> result) =>
      when(() => repository.deleteHabit(any())).thenAnswer((_) async => result);

  void stubGet(Either<Failure, Habit> result) =>
      when(() => repository.getHabit('h1')).thenAnswer((_) async => result);

  HabitFormCubit newHabit() {
    final cubit = HabitFormCubit(repository, defaultIconKey: 'water');
    addTearDown(cubit.close);
    return cubit;
  }

  /// An edit-mode Cubit, after the stored habit has been read.
  Future<HabitFormCubit> editing() async {
    stubGet(Right<Failure, Habit>(stored));
    final cubit = HabitFormCubit(
      repository,
      defaultIconKey: 'water',
      habitId: 'h1',
    );
    addTearDown(cubit.close);
    await pump();
    return cubit;
  }

  /// The statuses the Cubit goes through while [action] runs.
  Future<List<HabitFormStatus>> statusesDuring(
    HabitFormCubit cubit,
    Future<void> Function() action,
  ) async {
    final seen = <HabitFormStatus>[];
    final subscription = cubit.stream.map((s) => s.status).listen(seen.add);
    await action();
    await pump();
    await subscription.cancel();
    return seen;
  }

  group('adding a habit', () {
    test('starts ready with the defaults and no errors', () {
      final state = newHabit().state;

      expect(state.status, HabitFormStatus.ready);
      expect(state.isEditing, isFalse);
      expect(state.name, '');
      expect(state.iconKey, 'water');
      expect(state.color, HabitColor.orange);
      expect(state.dailyTarget, 1);
      expect(state.days, HabitSchedule.everyDay().days);
      expect(state.nameError, isNull);
      expect(state.daysError, isNull);
      expect(state.isDirty, isFalse);
      expect(state.scheduleChanged, isFalse);
    });

    group('name', () {
      test('has no error until the user edits it', () {
        expect(newHabit().state.nameError, isNull);
      });

      test('an empty or blank name is an error once touched', () {
        final cubit = newHabit()..nameChanged('a');
        expect(cubit.state.nameError, isNull);

        cubit.nameChanged('');
        expect(cubit.state.nameError, ValidationReason.nameEmpty);

        cubit.nameChanged('   ');
        expect(cubit.state.nameError, ValidationReason.nameEmpty);
      });

      test('allows exactly 50 characters and rejects 51', () {
        final cubit = newHabit()..nameChanged('a' * 50);
        expect(cubit.state.nameError, isNull);
        expect(cubit.state.nameLength, 50);

        cubit.nameChanged('a' * 51);
        expect(cubit.state.nameError, ValidationReason.nameTooLong);
        expect(cubit.state.nameLength, 51);
      });

      test('surrounding spaces are not counted', () {
        final cubit = newHabit()..nameChanged('  ${'a' * 50}  ');

        expect(cubit.state.nameError, isNull);
        expect(cubit.state.nameLength, 50);
      });

      test('the counter and the rule count an emoji the same way (as 2)', () {
        final cubit = newHabit()..nameChanged('💧' * 25);
        expect(cubit.state.nameLength, 50);
        expect(cubit.state.nameError, isNull);

        cubit.nameChanged('💧' * 26);
        expect(cubit.state.nameLength, 52);
        expect(cubit.state.nameError, ValidationReason.nameTooLong);
      });
    });

    group('daily target', () {
      test('cannot go below the minimum', () {
        final cubit = newHabit();
        expect(cubit.state.canDecrementTarget, isFalse);

        cubit.decrementTarget();

        expect(cubit.state.dailyTarget, Habit.minDailyTarget);
      });

      test('steps up to the maximum and stops there', () {
        final cubit = newHabit();
        for (var i = 0; i < Habit.maxDailyTarget; i++) {
          cubit.incrementTarget();
        }
        expect(cubit.state.dailyTarget, Habit.maxDailyTarget);
        expect(cubit.state.canIncrementTarget, isFalse);
        expect(cubit.state.canDecrementTarget, isTrue);

        cubit.incrementTarget();

        expect(cubit.state.dailyTarget, Habit.maxDailyTarget);
      });
    });

    group('days', () {
      test('toggling removes and adds a day', () {
        final cubit = newHabit()..dayToggled(Weekday.monday);
        expect(cubit.state.days, isNot(contains(Weekday.monday)));
        expect(cubit.state.days, hasLength(6));

        cubit.dayToggled(Weekday.monday);
        expect(cubit.state.days, HabitSchedule.everyDay().days);
      });

      test('deselecting every day is an error, selecting one clears it', () {
        final cubit = newHabit();
        Weekday.values.forEach(cubit.dayToggled);
        expect(cubit.state.days, isEmpty);
        expect(cubit.state.daysError, ValidationReason.noDaysSelected);

        cubit.dayToggled(Weekday.saturday);

        expect(cubit.state.daysError, isNull);
        expect(cubit.state.days, {Weekday.saturday});
      });
    });

    test('icon: a known key is selected, an unknown one is ignored', () {
      final cubit = newHabit()..iconSelected('run');
      expect(cubit.state.iconKey, 'run');

      cubit.iconSelected('not-an-icon');

      expect(cubit.state.iconKey, 'run');
    });

    test('isDirty follows any change away from the defaults', () {
      final cubit = newHabit()..nameChanged('Read');
      expect(cubit.state.isDirty, isTrue);
      cubit.nameChanged('  ');
      expect(cubit.state.isDirty, isFalse);

      cubit.colorSelected(HabitColor.pink);
      expect(cubit.state.isDirty, isTrue);
      cubit.colorSelected(HabitColor.orange);
      expect(cubit.state.isDirty, isFalse);

      cubit.incrementTarget();
      expect(cubit.state.isDirty, isTrue);
      cubit.decrementTarget();
      expect(cubit.state.isDirty, isFalse);

      cubit.dayToggled(Weekday.friday);
      expect(cubit.state.isDirty, isTrue);
    });

    group('submit', () {
      test(
        'with an empty name it shows the error and writes nothing',
        () async {
          final cubit = newHabit();

          await cubit.submit();

          expect(cubit.state.status, HabitFormStatus.ready);
          expect(cubit.state.nameError, ValidationReason.nameEmpty);
          verifyNever(anyCreate);
        },
      );

      test('with no days it shows the error and writes nothing', () async {
        final cubit = newHabit()..nameChanged('Read');
        Weekday.values.forEach(cubit.dayToggled);

        await cubit.submit();

        expect(cubit.state.status, HabitFormStatus.ready);
        expect(cubit.state.daysError, ValidationReason.noDaysSelected);
        verifyNever(anyCreate);
      });

      test(
        'creates the habit with the chosen fields and a trimmed name',
        () async {
          stubCreate(Right<Failure, Habit>(stored));
          final cubit = newHabit()
            ..nameChanged('  Read  ')
            ..iconSelected('book')
            ..colorSelected(HabitColor.green)
            ..incrementTarget();
          for (final day in Weekday.values) {
            if (day != Weekday.monday) cubit.dayToggled(day);
          }

          final statuses = await statusesDuring(cubit, cubit.submit);

          expect(statuses, [HabitFormStatus.saving, HabitFormStatus.saved]);
          verify(
            () => repository.createHabit(
              name: 'Read',
              iconKey: 'book',
              color: HabitColor.green,
              dailyTarget: 2,
              schedule: HabitSchedule(const {Weekday.monday}),
            ),
          ).called(1);
        },
      );

      test(
        'a failed save goes back to ready and keeps what was typed',
        () async {
          stubCreate(const Left<Failure, Habit>(DatabaseFailure()));
          final cubit = newHabit()..nameChanged('Read');

          await cubit.submit();

          expect(cubit.state.status, HabitFormStatus.ready);
          expect(cubit.state.actionFailure, const DatabaseFailure());
          expect(cubit.state.name, 'Read');

          cubit.dismissActionFailure();

          expect(cubit.state.actionFailure, isNull);
        },
      );

      test('a second press while saving is ignored', () async {
        final pending = Completer<Either<Failure, Habit>>();
        when(anyCreate).thenAnswer((_) => pending.future);
        final cubit = newHabit()..nameChanged('Read');

        final first = cubit.submit();
        final second = cubit.submit();
        pending.complete(Right<Failure, Habit>(stored));
        await Future.wait([first, second]);

        verify(anyCreate).called(1);
      });

      test('the inputs are locked while saving', () async {
        final pending = Completer<Either<Failure, Habit>>();
        when(anyCreate).thenAnswer((_) => pending.future);
        final cubit = newHabit()..nameChanged('Read');

        final saving = cubit.submit();
        cubit
          ..nameChanged('Other')
          ..incrementTarget()
          ..dayToggled(Weekday.monday);
        pending.complete(Right<Failure, Habit>(stored));
        await saving;

        expect(cubit.state.name, 'Read');
        expect(cubit.state.dailyTarget, 1);
        expect(cubit.state.days, HabitSchedule.everyDay().days);
      });
    });

    test('delete does nothing when adding', () async {
      final cubit = newHabit();

      await cubit.delete();

      expect(cubit.state.status, HabitFormStatus.ready);
      verifyNever(() => repository.deleteHabit(any()));
    });
  });

  group('editing a habit', () {
    test(
      'starts loading and then fills the form from the stored habit',
      () async {
        stubGet(Right<Failure, Habit>(stored));
        final cubit = HabitFormCubit(
          repository,
          defaultIconKey: 'water',
          habitId: 'h1',
        );
        addTearDown(cubit.close);
        expect(cubit.state.status, HabitFormStatus.loading);

        await pump();

        final state = cubit.state;
        expect(state.status, HabitFormStatus.ready);
        expect(state.isEditing, isTrue);
        expect(state.habitId, 'h1');
        expect(state.name, 'Read');
        expect(state.iconKey, 'book');
        expect(state.color, HabitColor.green);
        expect(state.dailyTarget, 2);
        expect(state.days, {Weekday.monday, Weekday.friday});
        expect(state.isDirty, isFalse);
        expect(state.scheduleChanged, isFalse);
        expect(state.nameError, isNull);
      },
    );

    test('a habit that does not exist cannot be edited', () async {
      stubGet(const Left<Failure, Habit>(NotFoundFailure()));
      final cubit = HabitFormCubit(
        repository,
        defaultIconKey: 'water',
        habitId: 'h1',
      );
      addTearDown(cubit.close);

      await pump();

      expect(cubit.state.status, HabitFormStatus.loadFailed);
      expect(cubit.state.failure, const NotFoundFailure());
    });

    test('a failed load can be retried', () async {
      stubGet(const Left<Failure, Habit>(DatabaseFailure()));
      final cubit = HabitFormCubit(
        repository,
        defaultIconKey: 'water',
        habitId: 'h1',
      );
      addTearDown(cubit.close);
      await pump();
      expect(cubit.state.status, HabitFormStatus.loadFailed);

      stubGet(Right<Failure, Habit>(stored));
      await cubit.retry();

      expect(cubit.state.status, HabitFormStatus.ready);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.name, 'Read');
    });

    test('retry does nothing unless the load failed', () async {
      final cubit = await editing();

      await cubit.retry();

      verify(() => repository.getHabit('h1')).called(1);
    });

    test('isDirty compares the trimmed name with the stored one', () async {
      final cubit = await editing();

      cubit.nameChanged(' Read ');
      expect(cubit.state.isDirty, isFalse);

      cubit.nameChanged('Run');
      expect(cubit.state.isDirty, isTrue);
    });

    test(
      'changing the days raises the schedule warning, restoring clears it',
      () async {
        final cubit = await editing();

        cubit.dayToggled(Weekday.tuesday);
        expect(cubit.state.scheduleChanged, isTrue);
        expect(cubit.state.isDirty, isTrue);

        cubit.dayToggled(Weekday.tuesday);
        expect(cubit.state.scheduleChanged, isFalse);
        expect(cubit.state.isDirty, isFalse);
      },
    );

    group('submit', () {
      test('with nothing changed it closes without writing', () async {
        final cubit = await editing();

        final statuses = await statusesDuring(cubit, cubit.submit);

        expect(statuses, [HabitFormStatus.unchanged]);
        verifyNever(() => repository.updateHabit(any()));
      });

      test('updates the stored habit and keeps its id and createdAt', () async {
        stubUpdate(const Right<Failure, Unit>(unit));
        final cubit = await editing();
        cubit
          ..nameChanged('Run')
          ..incrementTarget();

        final statuses = await statusesDuring(cubit, cubit.submit);

        expect(statuses, [HabitFormStatus.saving, HabitFormStatus.saved]);
        verify(
          () => repository.updateHabit(
            stored.copyWith(name: 'Run', dailyTarget: 3),
          ),
        ).called(1);
      });

      test(
        'a habit deleted in the meantime ends the form as not found',
        () async {
          stubUpdate(const Left<Failure, Unit>(NotFoundFailure()));
          final cubit = await editing();
          cubit.nameChanged('Run');

          await cubit.submit();

          expect(cubit.state.status, HabitFormStatus.loadFailed);
          expect(cubit.state.failure, const NotFoundFailure());
        },
      );

      test('another failure goes back to ready and keeps the edits', () async {
        stubUpdate(const Left<Failure, Unit>(DatabaseFailure()));
        final cubit = await editing();
        cubit.nameChanged('Run');

        await cubit.submit();

        expect(cubit.state.status, HabitFormStatus.ready);
        expect(cubit.state.actionFailure, const DatabaseFailure());
        expect(cubit.state.name, 'Run');
      });
    });

    group('delete', () {
      test('deletes the habit and finishes as deleted', () async {
        stubDelete(const Right<Failure, Unit>(unit));
        final cubit = await editing();

        final statuses = await statusesDuring(cubit, cubit.delete);

        expect(statuses, [HabitFormStatus.deleting, HabitFormStatus.deleted]);
        verify(() => repository.deleteHabit('h1')).called(1);
      });

      test('a habit that is already gone counts as deleted', () async {
        stubDelete(const Left<Failure, Unit>(NotFoundFailure()));
        final cubit = await editing();

        await cubit.delete();

        expect(cubit.state.status, HabitFormStatus.deleted);
        expect(cubit.state.actionFailure, isNull);
      });

      test('a failure goes back to ready and reports it', () async {
        stubDelete(const Left<Failure, Unit>(DatabaseFailure()));
        final cubit = await editing();

        await cubit.delete();

        expect(cubit.state.status, HabitFormStatus.ready);
        expect(cubit.state.actionFailure, const DatabaseFailure());
      });
    });
  });

  group('HabitFormState', () {
    HabitFormState stateWith(Set<Weekday> days) => HabitFormState(
      habitId: null,
      status: HabitFormStatus.ready,
      name: 'Read',
      iconKey: 'book',
      color: HabitColor.green,
      dailyTarget: 2,
      days: days,
    );

    test('equality does not depend on the order the days were added', () {
      expect(
        stateWith({Weekday.monday, Weekday.friday}),
        stateWith({Weekday.friday, Weekday.monday}),
      );
      expect(
        stateWith({Weekday.monday, Weekday.friday}),
        isNot(stateWith({Weekday.monday})),
      );
    });
  });
}
