// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Evolo';

  @override
  String get homeTitle => 'Today';

  @override
  String get homePlaceholder => 'Your habits will show up here.';

  @override
  String get openThemeShowcase => 'Open Theme Showcase';

  @override
  String get switchLanguage => 'Switch language';

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
      zero: 'No days',
    );
    return '$_temp0';
  }

  @override
  String get pageNotFoundTitle => 'Page not found';

  @override
  String get pageNotFoundMessage => 'This page doesn\'t exist or was moved.';

  @override
  String get goHome => 'Go home';
}
