import 'package:evolo/core/di/injection.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/l10n/locale_cubit.dart';
import 'package:evolo/core/theme/app_theme.dart';
import 'package:evolo/core/theme/theme_mode_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class EvoloApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<LocaleCubit>()),
        BlocProvider.value(value: getIt<ThemeModeCubit>()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeModeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                debugShowCheckedModeBanner: false,
                onGenerateTitle: (context) => context.l10n.appTitle,
                routerConfig: getIt<GoRouter>(),
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  ...GlobalMaterialLocalizations.delegates,
                ],
                themeMode: themeMode,
                theme: AppTheme.light(locale),
                darkTheme: AppTheme.dark(locale),
              );
            },
          );
        },
      ),
    );
  }
}
