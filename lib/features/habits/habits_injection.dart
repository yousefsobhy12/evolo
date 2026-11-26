import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/features/habits/data/repositories/completion_repository_impl.dart';
import 'package:evolo/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:evolo/features/habits/domain/repositories/completion_repository.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/domain/usecases/get_streak_status.dart';
import 'package:evolo/features/habits/domain/usecases/get_today_items.dart';
import 'package:evolo/features/habits/domain/usecases/is_habit_due.dart';
import 'package:evolo/features/habits/presentation/cubit/all_habits_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_cubit.dart';
import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:get_it/get_it.dart';

/// Registers everything the habits feature needs.
/// Requires [AppDatabase] to be registered first by the core setup.
void registerHabitsFeature(GetIt getIt) {
  getIt
    ..registerLazySingleton<HabitRepository>(
      () => HabitRepositoryImpl(getIt<AppDatabase>().habitsDao),
    )
    ..registerLazySingleton<CompletionRepository>(
      () => CompletionRepositoryImpl(getIt<AppDatabase>().completionsDao),
    )
    ..registerLazySingleton<IsHabitDue>(IsHabitDue.new)
    ..registerLazySingleton<GetStreakStatus>(
      () => GetStreakStatus(isHabitDue: getIt<IsHabitDue>()),
    )
    ..registerLazySingleton<GetTodayItems>(
      () => GetTodayItems(
        isHabitDue: getIt<IsHabitDue>(),
        getStreakStatus: getIt<GetStreakStatus>(),
      ),
    )
    // A screen Cubit: every screen instance gets its own (and closes it).
    ..registerFactory<TodayCubit>(
      () => TodayCubit(
        getIt<HabitRepository>(),
        getIt<CompletionRepository>(),
        getIt<GetTodayItems>(),
      ),
    )
    ..registerFactory<AllHabitsCubit>(
      () => AllHabitsCubit(getIt<HabitRepository>()),
    )
    // The add / edit form. The parameter is the habit id: null adds a new
    // habit, an id edits that habit (`getIt<HabitFormCubit>(param1: id)`).
    ..registerFactoryParam<HabitFormCubit, String?, void>(
      (habitId, _) => HabitFormCubit(
        getIt<HabitRepository>(),
        habitId: habitId,
        defaultIconKey: HabitIcons.keys.first,
      ),
    );
}
