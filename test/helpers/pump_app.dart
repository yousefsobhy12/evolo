import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

/// Call once in `setUpAll`: `DateFormat` needs the locale data loaded.
Future<void> initializeTestLocales() async {
  await initializeDateFormatting('ar');
  await initializeDateFormatting('en');
}

/// Pumps [home] (or [router]) inside the real theme and localizations.
///
/// The default size is 360x800 at pixel ratio 1: the narrowest phone the
/// design must survive (S6 criterion). Note: widget tests draw text with the
/// Ahem test font, whose glyphs are wider than Outfit/Readex Pro, so an
/// overflow-free result here is a conservative check, not a replacement for
/// looking at a real 360 screen.
Future<void> pumpApp(
  WidgetTester tester, {
  Widget? home,
  GoRouter? router,
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  double textScale = 1,
  Size size = const Size(360, 800),
}) async {
  assert(
    (home == null) != (router == null),
    'Pass exactly one of home or router',
  );
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  Widget scaled(BuildContext context, Widget? child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  );

  const delegates = [
    AppLocalizations.delegate,
    ...GlobalMaterialLocalizations.delegates,
  ];
  final themeMode = brightness == Brightness.dark
      ? ThemeMode.dark
      : ThemeMode.light;

  if (router != null) {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: delegates,
        theme: AppTheme.light(locale),
        darkTheme: AppTheme.dark(locale),
        themeMode: themeMode,
        builder: scaled,
      ),
    );
  } else {
    await tester.pumpWidget(
      MaterialApp(
        home: home,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: delegates,
        theme: AppTheme.light(locale),
        darkTheme: AppTheme.dark(locale),
        themeMode: themeMode,
        builder: scaled,
      ),
    );
  }
  await tester.pump();
}
