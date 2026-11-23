import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name (task switcher / OS label).
  ///
  /// In en, this message translates to:
  /// **'Evolo'**
  String get appTitle;

  /// Temporary Home title, replaced by the real Today screen in S6.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get homeTitle;

  /// Temporary Home body text.
  ///
  /// In en, this message translates to:
  /// **'Your habits will show up here.'**
  String get homePlaceholder;

  /// Dev-only button.
  ///
  /// In en, this message translates to:
  /// **'Open Theme Showcase'**
  String get openThemeShowcase;

  /// Tooltip/label for the language toggle.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get switchLanguage;

  /// Number of days (streak length, frequency...).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No days} one{{count} day} other{{count} days}}'**
  String dayCount(int count);

  /// Title of the route error screen.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFoundTitle;

  /// Body of the route error screen.
  ///
  /// In en, this message translates to:
  /// **'This page doesn\'t exist or was moved.'**
  String get pageNotFoundMessage;

  /// Button on the route error screen.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get goHome;

  /// Title of the Today screen.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTitle;

  /// Section heading above the list of habits on the Today screen.
  ///
  /// In en, this message translates to:
  /// **'Daily routine'**
  String get todayDailyRoutine;

  /// Tooltip and screen-reader label of the button that shows the week before.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get previousWeek;

  /// Tooltip and screen-reader label of the button that shows the week after.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get nextWeek;

  /// Button that returns the Today screen to the current day.
  ///
  /// In en, this message translates to:
  /// **'Back to today'**
  String get backToToday;

  /// A habit's current streak, shown under its name. The count is at least 1.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Streak: 1 day} other{Streak: {count} days}}'**
  String streakCurrent(int count);

  /// Shown under a habit that has no streak yet.
  ///
  /// In en, this message translates to:
  /// **'Start your streak today'**
  String get streakStart;

  /// Short warning next to the streak: today is not done yet and the streak would break if the day ended now.
  ///
  /// In en, this message translates to:
  /// **'At risk'**
  String get streakAtRisk;

  /// Screen-reader label for the freeze badge. A streak freeze covers one missed day automatically so the streak does not break.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 streak freeze available} other{{count} streak freezes available}}'**
  String streakFreezesAvailable(int count);

  /// Screen-reader label of the progress of a habit with a daily goal above 1, for example 3 of 8 glasses.
  ///
  /// In en, this message translates to:
  /// **'{count} of {target} done'**
  String habitProgressSemantics(int count, int target);

  /// Tooltip and screen-reader label of the check circle of a habit that is not done.
  ///
  /// In en, this message translates to:
  /// **'Complete {name}'**
  String completeHabit(String name);

  /// Tooltip and screen-reader label of the check circle of a habit that is done.
  ///
  /// In en, this message translates to:
  /// **'Undo {name}'**
  String undoHabit(String name);

  /// Tooltip and label of the button that adds one to a habit's count for the day.
  ///
  /// In en, this message translates to:
  /// **'Add one'**
  String get addOne;

  /// Tooltip and screen-reader label of the + button of a habit with a daily goal above 1, for example "Add one to Drink water".
  ///
  /// In en, this message translates to:
  /// **'Add one to {name}'**
  String addOneTo(String name);

  /// Tooltip and label of the button that removes one from a habit's count for the day.
  ///
  /// In en, this message translates to:
  /// **'Remove one'**
  String get removeOne;

  /// Tooltip and label of the floating button that opens the new-habit form.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get addHabit;

  /// Empty state title when no habit exists yet.
  ///
  /// In en, this message translates to:
  /// **'Start your first habit'**
  String get emptyNoHabitsTitle;

  /// Empty state message when no habit exists yet.
  ///
  /// In en, this message translates to:
  /// **'Small steps every day add up. Create a habit and build your streak.'**
  String get emptyNoHabitsMessage;

  /// Button of the empty state when no habit exists yet.
  ///
  /// In en, this message translates to:
  /// **'Add a habit'**
  String get emptyNoHabitsAction;

  /// Empty state title when habits exist but none is scheduled for the selected day.
  ///
  /// In en, this message translates to:
  /// **'A rest day'**
  String get emptyNothingDueTitle;

  /// Empty state message when habits exist but none is scheduled for the selected day.
  ///
  /// In en, this message translates to:
  /// **'No habits are scheduled for this day.'**
  String get emptyNothingDueMessage;

  /// Error state title of the Today screen.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your habits'**
  String get loadErrorTitle;

  /// Error state message of the Today screen.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while reading your data. Please try again.'**
  String get loadErrorMessage;

  /// Button that retries a failed load.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// SnackBar shown when marking a habit done (or undoing it) fails.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save that change. Please try again.'**
  String get actionErrorMessage;

  /// Screen-reader label of a loading indicator.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Title of the reminder card (shown on Today from S10 when no reminder is set).
  ///
  /// In en, this message translates to:
  /// **'Never miss a habit'**
  String get reminderCardTitle;

  /// Message of the reminder card.
  ///
  /// In en, this message translates to:
  /// **'Pick a time and we\'ll remind you gently.'**
  String get reminderCardMessage;

  /// Button of the reminder card that opens the reminder setup.
  ///
  /// In en, this message translates to:
  /// **'Set now'**
  String get reminderCardAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
