import 'package:evolo/core/theme/app_theme.dart';
import 'package:evolo/dev/theme_showcase_page.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const EvoloApp());
}

class EvoloApp extends StatefulWidget {
  const new({super.key});

  @override
  State<EvoloApp> createState() => _EvoloAppState();
}

class _EvoloAppState extends State<EvoloApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('ar');

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'ar'
          ? const Locale('en')
          : const Locale('ar');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Evolo',
      locale: _locale,
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      themeMode: _themeMode,
      theme: AppTheme.light(_locale),
      darkTheme: AppTheme.dark(_locale),
      home: ThemeShowcasePage(
        onToggleTheme: _toggleTheme,
        onToggleLocale: _toggleLocale,
      ),
    );
  }
}
