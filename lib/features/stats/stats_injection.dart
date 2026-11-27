import 'package:evolo/features/habits/domain/repositories/completion_repository.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/domain/usecases/get_streak_status.dart';
import 'package:evolo/features/habits/domain/usecases/is_habit_due.dart';
import 'package:evolo/features/stats/domain/usecases/get_habit_stats.dart';
import 'package:evolo/features/stats/presentation/cubit/stats_cubit.dart';
import 'package:get_it/get_it.dart';

/// Registers everything the statistics feature needs.
/// It reads the habits feature's repositories and usecases, so
/// `registerHabitsFeature` must run too.
void registerStatsFeature(GetIt getIt) {
  getIt
    ..registerLazySingleton<GetHabitStats>(
      () => GetHabitStats(
        isHabitDue: getIt<IsHabitDue>(),
        getStreakStatus: getIt<GetStreakStatus>(),
      ),
    )
    // A screen Cubit: every screen instance gets its own (and closes it).
    ..registerFactory<StatsCubit>(
      () => StatsCubit(
        getIt<HabitRepository>(),
        getIt<CompletionRepository>(),
        getIt<GetHabitStats>(),
      ),
    );
}
