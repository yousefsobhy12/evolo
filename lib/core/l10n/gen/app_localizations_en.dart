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

  @override
  String get todayTitle => 'Today';

  @override
  String get todayDailyRoutine => 'Daily routine';

  @override
  String get previousWeek => 'Previous week';

  @override
  String get nextWeek => 'Next week';

  @override
  String get backToToday => 'Back to today';

  @override
  String streakCurrent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Streak: $count days',
      one: 'Streak: 1 day',
    );
    return '$_temp0';
  }

  @override
  String get streakStart => 'Start your streak today';

  @override
  String get streakAtRisk => 'At risk';

  @override
  String streakFreezesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count streak freezes available',
      one: '1 streak freeze available',
    );
    return '$_temp0';
  }

  @override
  String habitProgressSemantics(int count, int target) {
    return '$count of $target done';
  }

  @override
  String completeHabit(String name) {
    return 'Complete $name';
  }

  @override
  String undoHabit(String name) {
    return 'Undo $name';
  }

  @override
  String get addOne => 'Add one';

  @override
  String addOneTo(String name) {
    return 'Add one to $name';
  }

  @override
  String get removeOne => 'Remove one';

  @override
  String get addHabit => 'Add habit';

  @override
  String get emptyNoHabitsTitle => 'Start your first habit';

  @override
  String get emptyNoHabitsMessage =>
      'Small steps every day add up. Create a habit and build your streak.';

  @override
  String get emptyNoHabitsAction => 'Add a habit';

  @override
  String get emptyNothingDueTitle => 'A rest day';

  @override
  String get emptyNothingDueMessage => 'No habits are scheduled for this day.';

  @override
  String get loadErrorTitle => 'Couldn\'t load your habits';

  @override
  String get loadErrorMessage =>
      'Something went wrong while reading your data. Please try again.';

  @override
  String get retry => 'Try again';

  @override
  String get actionErrorMessage =>
      'Couldn\'t save that change. Please try again.';

  @override
  String get loading => 'Loading';

  @override
  String get reminderCardTitle => 'Never miss a habit';

  @override
  String get reminderCardMessage => 'Pick a time and we\'ll remind you gently.';

  @override
  String get reminderCardAction => 'Set now';
}
