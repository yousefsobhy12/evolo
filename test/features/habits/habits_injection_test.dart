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
import 'package:evolo/features/habits/habits_injection.dart';
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

  test('resolves the completion repository and both usecases', () {
    expect(getIt<CompletionRepository>(), isA<CompletionRepositoryImpl>());
    expect(getIt<GetStreakStatus>(), isNotNull);
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
}
