import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/data/repositories/completion_repository_impl.dart';
import 'package:evolo/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/completion_repository.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/domain/usecases/get_streak_status.dart';
import 'package:evolo/features/habits/domain/usecases/get_today_items.dart';
import 'package:evolo/features/habits/habits_injection.dart';
import 'package:evolo/features/habits/presentation/cubit/all_habits_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  late GetIt getIt;

  setUp(() {
    getIt = GetIt.asNewInstance();
    addTearDown(getIt.reset);
    getIt.registerSingleton<AppDatabase>(
      AppDatabase(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      ),
      dispose: (database) => database.close(),
    );
    registerHabitsFeature(getIt);
  });

  test('registerHabitsFeature resolves a working HabitRepository', () async {
    final repository = getIt<HabitRepository>();
    expect(repository, isA<HabitRepositoryImpl>());
    final first = await repository.watchHabits().first;
    expect(first.getOrElse((_) => fail('expected Right')), isEmpty);
  });

  test('resolves the completion repository and the usecases', () {
    expect(getIt<CompletionRepository>(), isA<CompletionRepositoryImpl>());
    expect(getIt<GetStreakStatus>(), isNotNull);
    expect(getIt<GetTodayItems>(), isNotNull);
  });

  test('the pieces work together: create, complete, read the streak', () async {
    final habit = (await getIt<HabitRepository>().createHabit(
      name: 'Read',
      iconKey: 'book',
      color: HabitColor.orange,
      dailyTarget: 1,
      schedule: HabitSchedule.everyDay(),
    )).getOrElse((_) => fail('createHabit should succeed'));
    final today = CalendarDay.fromDateTime(DateTime.now());

    await getIt<CompletionRepository>().setCount(
      habitId: habit.id,
      day: today,
      count: 1,
    );
    final completions =
        (await getIt<CompletionRepository>().watchForHabit(habit.id).first)
            .getOrElse((_) => fail('expected Right'));
    final streak = getIt<GetStreakStatus>()(
      habit: habit,
      completions: completions,
      today: today,
    );

    expect(streak.current, 1);
    expect(streak.isTodayAtRisk, isFalse);
  });

  test('TodayCubit is a factory: every resolve is a new instance', () {
    final first = getIt<TodayCubit>();
    final second = getIt<TodayCubit>();
    addTearDown(first.close);
    addTearDown(second.close);

    expect(first, isNot(same(second)));
  });

  test('AllHabitsCubit is a factory', () {
    final first = getIt<AllHabitsCubit>();
    final second = getIt<AllHabitsCubit>();
    addTearDown(first.close);
    addTearDown(second.close);

    expect(first, isNot(same(second)));
  });

  test('TodayCubit works end to end on the real repositories', () async {
    await getIt<HabitRepository>().createHabit(
      name: 'Read',
      iconKey: 'book',
      color: HabitColor.orange,
      dailyTarget: 1,
      schedule: HabitSchedule.everyDay(),
    );
    final cubit = getIt<TodayCubit>();
    addTearDown(cubit.close);

    final loaded = await waitFor(cubit, (s) => s.status == TodayStatus.success);
    expect(loaded.items.single.count, 0);
    expect(loaded.items.single.isCompleted, isFalse);

    await cubit.tapCheck(loaded.items.single);

    final done = await waitFor(
      cubit,
      (s) => s.items.isNotEmpty && s.items.single.isCompleted,
    );
    expect(done.items.single.count, 1);
    expect(done.items.single.streak.current, 1);
    expect(done.items.single.streak.isTodayAtRisk, isFalse);
  });

  test(
    'deleting a habit empties Today, and a late tap on its card is ignored',
    () async {
      final habit = (await getIt<HabitRepository>().createHabit(
        name: 'Read',
        iconKey: 'book',
        color: HabitColor.orange,
        dailyTarget: 1,
        schedule: HabitSchedule.everyDay(),
      )).getOrElse((_) => fail('createHabit should succeed'));
      final cubit = getIt<TodayCubit>();
      addTearDown(cubit.close);
      final loaded = await waitFor(
        cubit,
        (s) => s.status == TodayStatus.success && s.items.isNotEmpty,
      );
      // The card the user is still looking at when the habit disappears.
      final staleItem = loaded.items.single;

      await getIt<HabitRepository>().deleteHabit(habit.id);
      final empty = await waitFor(
        cubit,
        (s) => s.status == TodayStatus.success && !s.hasAnyHabit,
      );
      expect(empty.emptyReason, TodayEmptyReason.noHabits);

      await cubit.tapCheck(staleItem);

      expect(cubit.state.actionFailure, isNull);
      expect(cubit.state.status, TodayStatus.success);
    },
  );
}

/// The current state if it already matches, otherwise the first emitted
/// state that does. Fails the test after 5 seconds.
Future<TodayState> waitFor(
  TodayCubit cubit,
  bool Function(TodayState) condition,
) async {
  if (condition(cubit.state)) return cubit.state;
  return await cubit.stream
      .firstWhere(condition)
      .timeout(const Duration(seconds: 5));
}
