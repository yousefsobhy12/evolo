import 'package:evolo/core/database/app_database.dart';
import 'package:evolo/core/l10n/locale_cubit.dart';
import 'package:evolo/core/router/app_router.dart';
import 'package:evolo/core/theme/theme_mode_cubit.dart';
import 'package:evolo/features/habits/habits_injection.dart';
import 'package:evolo/features/stats/stats_injection.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

final GetIt getIt = GetIt.instance;

/// Manual registration (no injectable, see project decisions).
/// Each feature adds its own `registerXxx(getIt)` function in later sessions.
Future<void> configureDependencies() async {
  getIt
    ..registerLazySingleton<LocaleCubit>(
      () => LocaleCubit(
        initial: LocaleCubit.resolve(
          WidgetsBinding.instance.platformDispatcher.locale,
        ),
      ),
    )
    ..registerLazySingleton<ThemeModeCubit>(ThemeModeCubit.new)
    ..registerLazySingleton<AppDatabase>(
      AppDatabase.open,
      dispose: (database) => database.close(),
    )
    ..registerLazySingleton<GoRouter>(createAppRouter);

  registerHabitsFeature(getIt);
  registerStatsFeature(getIt);
}
