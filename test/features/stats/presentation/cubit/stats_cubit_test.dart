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
import 'package:evolo/features/stats/domain/entities/completion_rate.dart';
import 'package:evolo/features/stats/domain/entities/stats_period.dart';
import 'package:evolo/features/stats/domain/usecases/get_habit_stats.dart';
import 'package:evolo/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:evolo/features/stats/presentation/cubit/stats_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository;

class MockCompletionRepository extends Mock implements CompletionRepository;

void main() {
  // 2026-03-18 is a Wednesday. With a Saturday week start the week began on
  // March 14.
  CalendarDay march(int day) => CalendarDay(2026, 3, day);

  final habit = Habit(
    id: 'h1',
    name: 'Read',
    iconKey: 'book',
    color: HabitColor.orange,
    dailyTarget: 1,
    schedule: HabitSchedule.everyDay(),
    createdAt: DateTime(2026, 3, 1, 9),
  );

  List<Completion> doneOn(List<int> days) => [
    for (final day in days)
      Completion(habitId: 'h1', day: march(day), count: 1, target: 1),
  ];

  // March 14 to 17 done, today still open.
  final fourDays = doneOn([14, 15, 16, 17]);

  late MockHabitRepository habitRepository;
  late MockCompletionRepository completionRepository;
  late StreamController<Either<Failure, List<Habit>>> habitsStream;
  late StreamController<Either<Failure, List<Completion>>> completionsStream;
  late DateTime currentTime;

  setUp(() {
    currentTime = DateTime(2026, 3, 18, 14);
    habitRepository = MockHabitRepository();
    completionRepository = MockCompletionRepository();
    // Broadcast so `retry()` can listen again after cancelling.
    habitsStream = StreamController<Either<Failure, List<Habit>>>.broadcast();
    completionsStream =
        StreamController<Either<Failure, List<Completion>>>.broadcast();

    when(habitRepository.watchHabits).thenAnswer((_) => habitsStream.stream);
    when(completionRepository.watchAll)
        .thenAnswer((_) => completionsStream.stream);
  });

  tearDown(() async {
    await habitsStream.close();
    await completionsStream.close();
  });

  StatsCubit buildCubit({Weekday weekStart = Weekday.saturday}) => StatsCubit(
    habitRepository,
    completionRepository,
    const GetHabitStats(),
    weekStart: weekStart,
    now: () => currentTime,
  );

  /// Lets queued stream events reach the Cubit.
  Future<void> pump() => Future<void>.delayed(Duration.zero);

  void deliver({List<Habit>? habits, List<Completion>? completions}) {
    habitsStream.add(Right(habits ?? [habit]));
    completionsStream.add(Right(completions ?? fourDays));
  }

  Future<StatsCubit> loaded({
    List<Habit>? habits,
    List<Completion>? completions,
  }) async {
    final cubit = buildCubit();
    addTearDown(cubit.close);
    deliver(habits: habits, completions: completions);
    await pump();
    return cubit;
  }

  CompletionRate rate(int completed, int due) =>
      CompletionRate(completedDays: completed, dueDays: due);

  const dbFailure = DatabaseFailure();

  group('loading', () {
    test('starts loading, on the week', () {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      expect(cubit.state, const StatsState());
      expect(cubit.state.isEmpty, isFalse);
    });

    blocTest<StatsCubit, StatsState>(
      'emits nothing until both streams have delivered',
      build: buildCubit,
      act: (_) => habitsStream.add(Right([habit])),
      expect: () => const <StatsState>[],
    );

    test('then shows the numbers of the current week', () async {
      final cubit = await loaded();

      expect(cubit.state.status, StatsStatus.success);
      expect(cubit.state.report?.start, march(14));
      expect(cubit.state.report?.end, march(18));
      expect(cubit.state.report?.rate, rate(4, 4));
      expect(cubit.state.isEmpty, isFalse);
    });

    test('the week start is a parameter', () async {
      final cubit = buildCubit(weekStart: Weekday.sunday);
      addTearDown(cubit.close);
      deliver();
      await pump();

      expect(cubit.state.report?.start, march(15));
      expect(cubit.state.report?.rate, rate(3, 3));
    });

    test('no habits is a loaded, empty state', () async {
      final cubit = await loaded(habits: [], completions: []);

      expect(cubit.state.status, StatsStatus.success);
      expect(cubit.state.isEmpty, isTrue);
    });

    test('a new completion updates the report', () async {
      final cubit = await loaded();

      completionsStream.add(Right(doneOn([14, 15, 16, 17, 18])));
      await pump();

      expect(cubit.state.report?.rate, rate(5, 5));
    });
  });

  group('failure', () {
    const failed = StatsState(status: StatsStatus.failure, failure: dbFailure);

    blocTest<StatsCubit, StatsState>(
      'a habits read error is a failure state',
      build: buildCubit,
      act: (_) => habitsStream.add(const Left(dbFailure)),
      expect: () => const [failed],
    );

    test('a completions error after loading drops the report', () async {
      final cubit = await loaded();

      completionsStream.add(const Left(dbFailure));
      await pump();

      expect(cubit.state, failed);
      expect(cubit.state.isEmpty, isFalse);
    });

    test('recovers by itself when the stream delivers again', () async {
      final cubit = await loaded();
      completionsStream.add(const Left(dbFailure));
      await pump();

      completionsStream.add(Right(fourDays));
      await pump();

      expect(cubit.state.status, StatsStatus.success);
      expect(cubit.state.failure, isNull);
    });

    test('retry goes back to loading and listens again', () async {
      final cubit = await loaded();
      habitsStream.add(const Left(dbFailure));
      await pump();

      await cubit.retry();
      expect(cubit.state, const StatsState());

      deliver();
      await pump();
      expect(cubit.state.status, StatsStatus.success);
      verify(habitRepository.watchHabits).called(2);
      verify(completionRepository.watchAll).called(2);
    });

    test('a double retry subscribes only once more', () async {
      final cubit = await loaded();

      await Future.wait([cubit.retry(), cubit.retry()]);

      verify(habitRepository.watchHabits).called(2);
      verify(completionRepository.watchAll).called(2);
    });
  });

  group('period', () {
    test('switching to the month recalculates', () async {
      final cubit = await loaded();

      cubit.selectPeriod(StatsPeriod.month);

      expect(cubit.state.period, StatsPeriod.month);
      expect(cubit.state.report?.period, StatsPeriod.month);
      expect(cubit.state.report?.start, march(1));
      expect(cubit.state.report?.rate, rate(4, 17));
    });

    blocTest<StatsCubit, StatsState>(
      'selecting the shown period emits nothing',
      build: buildCubit,
      act: (cubit) => cubit.selectPeriod(StatsPeriod.week),
      expect: () => const <StatsState>[],
    );

    test('a period picked while loading is used when data arrives', () async {
      final cubit = buildCubit();
      addTearDown(cubit.close);

      cubit.selectPeriod(StatsPeriod.month);
      expect(cubit.state, const StatsState(period: StatsPeriod.month));

      deliver();
      await pump();
      expect(cubit.state.report?.period, StatsPeriod.month);
    });

    test('the period survives a failure and a retry', () async {
      final cubit = await loaded();
      cubit.selectPeriod(StatsPeriod.month);

      habitsStream.add(const Left(dbFailure));
      await pump();
      expect(cubit.state.period, StatsPeriod.month);

      await cubit.retry();
      expect(cubit.state.period, StatsPeriod.month);
    });
  });

  group('a new day', () {
    test('refreshToday moves the report to the new day', () async {
      final cubit = await loaded();

      currentTime = DateTime(2026, 3, 19, 8);
      cubit.refreshToday();

      // The 18th is now a past day that was missed.
      expect(cubit.state.report?.end, march(19));
      expect(cubit.state.report?.rate, rate(4, 5));
    });

    test('refreshToday does nothing on the same day', () async {
      final cubit = await loaded();
      final before = cubit.state;

      currentTime = DateTime(2026, 3, 18, 23);
      cubit.refreshToday();

      expect(cubit.state, same(before));
    });
  });

  group('close', () {
    test('cancels both subscriptions', () async {
      final cubit = buildCubit();

      await cubit.close();

      expect(habitsStream.hasListener, isFalse);
      expect(completionsStream.hasListener, isFalse);
    });

    test('during a retry leaves no subscription behind', () async {
      final cubit = buildCubit();

      final retrying = cubit.retry();
      await cubit.close();
      await retrying;

      expect(habitsStream.hasListener, isFalse);
      expect(completionsStream.hasListener, isFalse);
    });
  });
}
