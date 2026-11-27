import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/completion_repository.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/habits_injection.dart';
import 'package:evolo/features/stats/domain/entities/completion_rate.dart';
import 'package:evolo/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:evolo/features/stats/presentation/cubit/stats_state.dart';
import 'package:evolo/features/stats/stats_injection.dart';
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
    registerStatsFeature(getIt);
  });

  test('StatsCubit is a factory', () {
    final first = getIt<StatsCubit>();
    final second = getIt<StatsCubit>();
    addTearDown(first.close);
    addTearDown(second.close);

    expect(first, isNot(same(second)));
  });

  test('StatsCubit works end to end on the real repositories', () async {
    final habit = (await getIt<HabitRepository>().createHabit(
      name: 'Read',
      iconKey: 'book',
      color: HabitColor.orange,
      dailyTarget: 1,
      schedule: HabitSchedule.everyDay(),
    )).getOrElse((_) => fail('createHabit should succeed'));
    final cubit = getIt<StatsCubit>();
    addTearDown(cubit.close);

    await getIt<CompletionRepository>().setCount(
      habitId: habit.id,
      day: CalendarDay.fromDateTime(DateTime.now()),
      count: 1,
    );

    bool isDone(StatsState state) => state.report?.totalCheckIns == 1;
    final done = isDone(cubit.state)
        ? cubit.state
        : await cubit.stream
              .firstWhere(isDone)
              .timeout(const Duration(seconds: 5));

    expect(
      done.report?.rate,
      const CompletionRate(completedDays: 1, dueDays: 1),
    );
    expect(done.report?.bestStreak, 1);
  });
}
