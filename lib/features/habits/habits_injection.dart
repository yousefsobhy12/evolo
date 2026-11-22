import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/features/habits/data/repositories/completion_repository_impl.dart';
import 'package:evolo/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:evolo/features/habits/domain/repositories/completion_repository.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/domain/usecases/get_streak_status.dart';
import 'package:evolo/features/habits/domain/usecases/is_habit_due.dart';
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
    );
}
