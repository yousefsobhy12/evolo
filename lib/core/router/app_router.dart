import 'package:evolo/core/l10n/locale_cubit.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/router/route_error_page.dart';
import 'package:evolo/core/theme/theme_mode_cubit.dart';
import 'package:evolo/dev/home_page.dart';
import 'package:evolo/dev/theme_showcase_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    debugLogDiagnostics: kDebugMode,
    errorBuilder: (context, state) => const RouteErrorPage(),
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
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
