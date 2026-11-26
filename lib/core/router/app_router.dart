import 'package:evolo/core/di/injection.dart';
import 'package:evolo/core/l10n/locale_cubit.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/router/route_error_page.dart';
import 'package:evolo/core/theme/theme_mode_cubit.dart';
import 'package:evolo/dev/theme_showcase_page.dart';
import 'package:evolo/features/habits/presentation/cubit/all_habits_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_cubit.dart';
import 'package:evolo/features/habits/presentation/pages/all_habits_page.dart';
import 'package:evolo/features/habits/presentation/pages/habit_form_page.dart';
import 'package:evolo/features/habits/presentation/pages/today_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.today,
    debugLogDiagnostics: kDebugMode,
    errorBuilder: (context, state) => const RouteErrorPage(),
    routes: [
      GoRoute(
        path: AppRoutes.today,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<TodayCubit>(),
          child: const TodayPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.allHabits,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<AllHabitsCubit>(),
          child: const AllHabitsPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.newHabit,
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<HabitFormCubit>(),
          child: const HabitFormPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.editHabitPattern,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<HabitFormCubit>(param1: state.pathParameters['id']),
          child: const HabitFormPage(),
        ),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.themeShowcase,
          builder: (context, state) => ThemeShowcasePage(
            onToggleTheme: context.read<ThemeModeCubit>().toggle,
            onToggleLocale: context.read<LocaleCubit>().toggle,
          ),
        ),
    ],
  );
}
