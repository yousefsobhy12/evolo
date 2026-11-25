import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/habits_injection.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_state.dart';
import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The add / edit form's Cubit as the Router will get it:
/// `getIt<HabitFormCubit>(param1: habitId)`, where the id is null to add.
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

  test('a null id gives a ready form for a new habit', () {
    final cubit = getIt<HabitFormCubit>();
    addTearDown(cubit.close);

    expect(cubit.state.status, HabitFormStatus.ready);
    expect(cubit.state.isEditing, isFalse);
    expect(cubit.state.iconKey, HabitIcons.keys.first);
  });

  test('an id gives a form that loads that habit from the database', () async {
    final habit = (await getIt<HabitRepository>().createHabit(
      name: 'Read',
      iconKey: 'book',
      color: HabitColor.green,
      dailyTarget: 2,
      schedule: HabitSchedule.everyDay(),
    )).getOrElse((_) => fail('createHabit should succeed'));

    final cubit = getIt<HabitFormCubit>(param1: habit.id);
    addTearDown(cubit.close);
    expect(cubit.state.status, HabitFormStatus.loading);
    final loaded = await cubit.stream
        .firstWhere((s) => s.status == HabitFormStatus.ready)
        .timeout(const Duration(seconds: 5));

    expect(loaded.isEditing, isTrue);
    expect(loaded.name, 'Read');
    expect(loaded.iconKey, 'book');
    expect(loaded.color, HabitColor.green);
    expect(loaded.dailyTarget, 2);
  });

  test('an unknown id ends as not found', () async {
    final cubit = getIt<HabitFormCubit>(param1: 'does-not-exist');
    addTearDown(cubit.close);

    final failed = await cubit.stream
        .firstWhere((s) => s.status == HabitFormStatus.loadFailed)
        .timeout(const Duration(seconds: 5));

    expect(failed.failure, isNotNull);
  });

  test('every resolve is a new Cubit', () {
    final first = getIt<HabitFormCubit>();
    final second = getIt<HabitFormCubit>();
    addTearDown(first.close);
    addTearDown(second.close);

    expect(identical(first, second), isFalse);
  });
}
