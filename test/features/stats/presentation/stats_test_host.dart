import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Wraps [child] with the real theme and localizations, so a statistics
/// widget is tested the way it is used.
Widget statsHost(
  Widget child, {
  Locale locale = const Locale('en'),
  bool dark = false,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    locale: locale,
    theme: dark ? AppTheme.dark(locale) : AppTheme.light(locale),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: app!,
    ),
    home: Scaffold(
      body: SafeArea(child: SingleChildScrollView(child: child)),
    ),
  );
}

/// A 360 x 800 phone, the narrowest screen the layout must survive.
void usePhoneSize(WidgetTester tester) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(360, 800);
  addTearDown(tester.view.reset);
}
