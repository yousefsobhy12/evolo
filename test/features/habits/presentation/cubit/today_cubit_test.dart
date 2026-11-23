import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/completion.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/completion_repository.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/domain/usecases/get_today_items.dart';
import 'package:evolo/features/habits/presentation/cubit/today_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository;

class MockCompletionRepository extends Mock implements CompletionRepository;

void main() {
  // 2026-11-22 is a Sunday, so with a Saturday week start the strip shows
  // Nov 21 .. Nov 27 and Nov 14 .. Nov 20 is the week before it.
  final today = CalendarDay(2026, 11, 22);
  CalendarDay nov(int day) => CalendarDay(2026, 11, day);

  late MockHabitRepository habitRepository;
  late MockCompletionRepository completionRepository;
  late StreamController<Either<Failure, List<Habit>>> habitsStream;
  late StreamController<Either<Failure, List<Completion>>> completionsStream;
  late DateTime currentTime;

  setUpAll(() => registerFallbackValue(today));

  setUp(() {
    currentTime = DateTime(2026, 11, 22, 14);
    habitRepository = MockHabitRepository();
    completionRepository = MockCompletionRepository();
    // Broadcast so `retry()` can listen again after cancelling.
    habitsStream = StreamController<Either<Failure, List<Habit>>>.broadcast();
    completionsStream =
        StreamController<Either<Failure, List<Completion>>>.broadcast();

    when(() => habitRepository.watchHabits())
        .thenAnswer((_) => habitsStream.stream);
    when(() => completionRepository.watchAll())
        .thenAnswer((_) => completionsStream.stream);
    when(
      () => completionRepository.adjustCount(
        habitId: any(named: 'habitId'),
        day: any(named: 'day'),
        delta: any(named: 'delta'),
      ),
    ).thenAnswer((_) async => const Right<Failure, Unit>(unit));
  });

  tearDown(() async {
    await habitsStream.close();
    await completionsStream.close();
  });

  Habit habit({String id = 'h1', int dailyTarget = 1, DateTime? createdAt}) =>
      Habit(
        id: id,
        name: 'Habit $id',
        iconKey: 'book',
        color: HabitColor.orange,
        dailyTarget: dailyTarget,
        schedule: HabitSchedule.everyDay(),
        createdAt: createdAt ?? DateTime(2026, 11, 1, 9),
      );

  Completion completion(
    String habitId,
    CalendarDay day, {
    int count = 1,
    int target = 1,
  }) => Completion(habitId: habitId, day: day, count: count, target: target);

  Either<Failure, List<Habit>> habitsOf(List<Habit> habits) => Right(habits);

  Either<Failure, List<Completion>> completionsOf(List<Completion> all) =>
      Right(all);

  const dbFailure = DatabaseFailure();

  TodayCubit buildCubit({Weekday weekStart = Weekday.saturday}) => TodayCubit(
    habitRepository,
    completionRepository,
    const GetTodayItems(),
    weekStart: weekStart,
    now: () => currentTime,
  );

  /// Lets queued stream events reach the Cubit.
  Future<void> pump() => Future<void>.delayed(Duration.zero);

  Future<TodayCubit> loaded({
    List<Habit>? habits,
    List<Completion> completions = const [],
  }) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    habitsStream.add(habitsOf(habits ?? [habit()]));
    completionsStream.add(completionsOf(completions));
    await pump();
    return cubit;
  }

  void stubAdjustToFail() {
    when(
      () => completionRepository.adjustCount(
        habitId: any(named: 'habitId'),
        day: any(named: 'day'),
        delta: any(named: 'delta'),
      ),
    ).thenAnswer((_) async => const Left<Failure, Unit>(NotFoundFailure()));
  }

  group('loading', () {
    test('starts loading, on today, with the strip already drawn', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state.status, TodayStatus.loading);
      expect(cubit.state.today, today);
      expect(cubit.state.selectedDay, today);
      expect(cubit.state.days, hasLength(7));
      expect(cubit.state.items, isEmpty);
    });

    test('stays loading until both streams have delivered', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      habitsStream.add(habitsOf([habit()]));
      await pump();

      expect(cubit.state.status, TodayStatus.loading);
      expect(cubit.state.hasAnyHabit, isFalse);
    });

    blocTest<TodayCubit, TodayState>(
      'emits a single success state once both streams have delivered',
      build: buildCubit,
      act: (_) {
        habitsStream.add(habitsOf([habit()]));
        completionsStream.add(completionsOf(const []));
      },
      expect: () => [
        isA<TodayState>()
            .having((s) => s.status, 'status', TodayStatus.success)
            .having((s) => s.items, 'items', hasLength(1)),
      ],
    );
  });

  group('data', () {
    test('lists the due habits with count, target and first day', () async {
      final cubit = await loaded();

      expect(cubit.state.status, TodayStatus.success);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.hasAnyHabit, isTrue);
      expect(cubit.state.firstSelectableDay, nov(1));
      final item = cubit.state.items.single;
      expect(item.habit.id, 'h1');
      expect(item.count, 0);
      expect(item.target, 1);
    });

    test(
      'no habits: empty list, and today is the first selectable day',
      () async {
        final cubit = await loaded(habits: const []);

        expect(cubit.state.status, TodayStatus.success);
        expect(cubit.state.emptyReason, TodayEmptyReason.noHabits);
        expect(cubit.state.firstSelectableDay, today);
      },
    );

    test('a new completion updates the item', () async {
      final cubit = await loaded();

      completionsStream.add(completionsOf([completion('h1', today)]));
      await pump();

      final item = cubit.state.items.single;
      expect(item.count, 1);
      expect(item.isCompleted, isTrue);
    });

    test('a habit added later shows up', () async {
      final cubit = await loaded();

      habitsStream.add(habitsOf([habit(), habit(id: 'h2')]));
      await pump();

      expect(cubit.state.items.map((i) => i.habit.id), ['h1', 'h2']);
    });
  });

  group('failures', () {
    blocTest<TodayCubit, TodayState>(
      'a habits failure emits a failure state',
      build: buildCubit,
      act: (_) => habitsStream.add(const Left<Failure, List<Habit>>(dbFailure)),
      expect: () => [
        isA<TodayState>()
            .having((s) => s.status, 'status', TodayStatus.failure)
            .having((s) => s.failure, 'failure', dbFailure),
      ],
    );

    test('a completions failure after loading empties the list', () async {
      final cubit = await loaded();

      completionsStream.add(const Left<Failure, List<Completion>>(dbFailure));
      await pump();

      expect(cubit.state.status, TodayStatus.failure);
      expect(cubit.state.failure, dbFailure);
      expect(cubit.state.items, isEmpty);
    });

    test('recovers by itself when the stream delivers again', () async {
      final cubit = await loaded();
      completionsStream.add(const Left<Failure, List<Completion>>(dbFailure));
      await pump();

      completionsStream.add(completionsOf(const []));
      await pump();

      expect(cubit.state.status, TodayStatus.success);
      expect(cubit.state.failure, isNull);
      expect(cubit.state.items, hasLength(1));
    });

    test('the strip and the selected day survive a failure', () async {
      final cubit = await loaded();
      cubit.selectDay(nov(20));

      completionsStream.add(const Left<Failure, List<Completion>>(dbFailure));
      await pump();

      expect(cubit.state.status, TodayStatus.failure);
      expect(cubit.state.selectedDay, nov(20));
      expect(cubit.state.days, hasLength(7));
    });

    test('retry listens to both streams again', () async {
      final cubit = await loaded();
      habitsStream.add(const Left<Failure, List<Habit>>(dbFailure));
      await pump();
      expect(cubit.state.status, TodayStatus.failure);

      await cubit.retry();

      expect(cubit.state.status, TodayStatus.loading);
      verify(() => habitRepository.watchHabits()).called(2);
      verify(() => completionRepository.watchAll()).called(2);

      habitsStream.add(habitsOf([habit()]));
      completionsStream.add(completionsOf(const []));
      await pump();

      expect(cubit.state.status, TodayStatus.success);
    });
  });

  group('day strip', () {
    blocTest<TodayCubit, TodayState>(
      'selectDay emits a state for the chosen past day',
      build: buildCubit,
      act: (cubit) async {
        habitsStream.add(habitsOf([habit()]));
        completionsStream.add(completionsOf(const []));
        await pump();
        cubit.selectDay(nov(20));
      },
      expect: () => [
        isA<TodayState>().having((s) => s.selectedDay, 'selectedDay', today),
        isA<TodayState>().having((s) => s.selectedDay, 'selectedDay', nov(20)),
      ],
    );

    test('a past day is judged by its own stored count and target', () async {
      final cubit = await loaded(
        habits: [habit(dailyTarget: 3)],
        completions: [completion('h1', nov(20), count: 2, target: 3)],
      );

      cubit.selectDay(nov(20));

      final item = cubit.state.items.single;
      expect(item.count, 2);
      expect(item.target, 3);
      expect(item.isCompleted, isFalse);
    });

    test('ignores a future day and a day before the first habit', () async {
      final cubit = await loaded();

      cubit
        ..selectDay(nov(23))
        ..selectDay(CalendarDay(2026, 10, 31));

      expect(cubit.state.selectedDay, today);
    });

    test('previousWeek, nextWeek and goToToday move the selection', () async {
      final cubit = await loaded();
      expect(cubit.state.canGoPrevious, isTrue);
      expect(cubit.state.canGoNext, isFalse);

      cubit.previousWeek();
      expect(cubit.state.selectedDay, nov(15));
      expect(cubit.state.days.first.day, nov(14));
      expect(cubit.state.canGoNext, isTrue);

      cubit.nextWeek();
      expect(cubit.state.selectedDay, today);
      expect(cubit.state.canGoNext, isFalse);

      cubit
        ..nextWeek()
        ..selectDay(nov(20));
      expect(cubit.state.selectedDay, nov(20));

      cubit.goToToday();
      expect(cubit.state.selectedDay, today);
    });

    test('previousWeek stops at the day the first habit was created', () async {
      final cubit = await loaded(
        habits: [habit(createdAt: DateTime(2026, 11, 18, 9))],
      );

      cubit.previousWeek();

      // One week back would be Nov 15, but nothing exists before Nov 18.
      expect(cubit.state.selectedDay, nov(18));
      expect(cubit.state.canGoPrevious, isFalse);

      cubit
        ..previousWeek()
        ..selectDay(nov(17));
      expect(cubit.state.selectedDay, nov(18));
    });

    test('the selection moves up when the oldest habit disappears', () async {
      final cubit = await loaded();
      cubit.selectDay(nov(5));

      habitsStream.add(
        habitsOf([habit(id: 'h2', createdAt: DateTime(2026, 11, 20, 9))]),
      );
      await pump();

      expect(cubit.state.selectedDay, nov(20));
      expect(cubit.state.items.single.habit.id, 'h2');
    });
  });

  group('refreshToday', () {
    test('follows to the new day when the user was on today', () async {
      final cubit = await loaded();

      currentTime = DateTime(2026, 11, 23, 0, 5);
      cubit.refreshToday();

      expect(cubit.state.today, nov(23));
      expect(cubit.state.selectedDay, nov(23));
    });

    test('keeps a past day the user had opened', () async {
      final cubit = await loaded();
      cubit.selectDay(nov(20));

      currentTime = DateTime(2026, 11, 23, 0, 5);
      cubit.refreshToday();

      expect(cubit.state.today, nov(23));
      expect(cubit.state.selectedDay, nov(20));
    });

    test('does nothing when the day has not changed', () async {
      final cubit = await loaded();
      final before = cubit.state;

      cubit.refreshToday();

      expect(cubit.state, before);
    });
  });

  group('completing habits', () {
    test('a tap on a goal-of-1 habit adds 1 on the selected day', () async {
      final cubit = await loaded();

      await cubit.tapCheck(cubit.state.items.single);

      verify(
        () => completionRepository.adjustCount(
          habitId: 'h1',
          day: today,
          delta: 1,
        ),
      ).called(1);
    });

    test('a tap on a done goal-of-1 habit clears it', () async {
      final cubit = await loaded(completions: [completion('h1', today)]);

      await cubit.tapCheck(cubit.state.items.single);

      verify(
        () => completionRepository.adjustCount(
          habitId: 'h1',
          day: today,
          delta: -1,
        ),
      ).called(1);
    });

    test('a tap on a finished counter does nothing', () async {
      final cubit = await loaded(
        habits: [habit(dailyTarget: 3)],
        completions: [completion('h1', today, count: 3, target: 3)],
      );

      await cubit.tapCheck(cubit.state.items.single);

      verifyNever(
        () => completionRepository.adjustCount(
          habitId: any(named: 'habitId'),
          day: any(named: 'day'),
          delta: any(named: 'delta'),
        ),
      );
    });

    test('minus removes one on the day being shown', () async {
      final cubit = await loaded(
        habits: [habit(dailyTarget: 8)],
        completions: [completion('h1', nov(20), count: 3, target: 8)],
      );
      cubit.selectDay(nov(20));

      await cubit.decrement(cubit.state.items.single);

      verify(
        () => completionRepository.adjustCount(
          habitId: 'h1',
          day: nov(20),
          delta: -1,
        ),
      ).called(1);
    });

    test('minus does nothing at zero', () async {
      final cubit = await loaded(habits: [habit(dailyTarget: 8)]);

      await cubit.decrement(cubit.state.items.single);

      verifyNever(
        () => completionRepository.adjustCount(
          habitId: any(named: 'habitId'),
          day: any(named: 'day'),
          delta: any(named: 'delta'),
        ),
      );
    });

    test('a failed write is surfaced once and can be dismissed', () async {
      final cubit = await loaded();
      stubAdjustToFail();

      await cubit.tapCheck(cubit.state.items.single);

      expect(cubit.state.actionFailure, const NotFoundFailure());
      expect(cubit.state.status, TodayStatus.success);
      expect(cubit.state.items, hasLength(1));

      cubit.dismissActionFailure();

      expect(cubit.state.actionFailure, isNull);
    });
  });

  test('close cancels both subscriptions', () async {
    final cubit = buildCubit();
    expect(habitsStream.hasListener, isTrue);
    expect(completionsStream.hasListener, isTrue);

    await cubit.close();

    expect(habitsStream.hasListener, isFalse);
    expect(completionsStream.hasListener, isFalse);
  });
}
