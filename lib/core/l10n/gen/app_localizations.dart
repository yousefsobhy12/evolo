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

  /// Title of the Today screen from 5:00 to 11:59.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// Title of the Today screen from 12:00 to 16:59.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// Title of the Today screen from 17:00 to 4:59.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// Section heading above the list of habits on the Today screen.
  ///
  /// In en, this message translates to:
  /// **'Daily routine'**
  String get todayDailyRoutine;

  /// Screen-reader action that shows the week before.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get previousWeek;

  /// Screen-reader action that shows the week after.
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

  /// Title of the add-habit screen.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabitTitle;

  /// Title of the edit-habit screen.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabitTitle;

  /// Label of the habit name field.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get habitNameLabel;

  /// Placeholder of the habit name field.
  ///
  /// In en, this message translates to:
  /// **'e.g. Drink water'**
  String get habitNameHint;

  /// Character counter under the habit name field, for example 12/50.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max}'**
  String habitNameCounter(int count, int max);

  /// Validation error when the habit name is empty.
  ///
  /// In en, this message translates to:
  /// **'Give your habit a name'**
  String get habitNameEmptyError;

  /// Validation error when the habit name is longer than the limit.
  ///
  /// In en, this message translates to:
  /// **'{max, plural, =1{Up to 1 character} other{Up to {max} characters}}'**
  String habitNameTooLongError(int max);

  /// Section label of the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get habitIconLabel;

  /// Section label of the color picker.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get habitColorLabel;

  /// Name of the orange habit color (screen readers).
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// Name of the green habit color (screen readers).
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// Name of the pink habit color (screen readers).
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// Section label of the daily goal stepper.
  ///
  /// In en, this message translates to:
  /// **'Set a goal'**
  String get habitTargetLabel;

  /// The daily goal as a phrase, shown between the - and + buttons.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Once a day} =2{Twice a day} other{{count} times a day}}'**
  String habitTargetSummary(int count);

  /// Tooltip and screen-reader label of the + button of the daily goal stepper.
  ///
  /// In en, this message translates to:
  /// **'Increase goal'**
  String get increaseTarget;

  /// Tooltip and screen-reader label of the - button of the daily goal stepper.
  ///
  /// In en, this message translates to:
  /// **'Decrease goal'**
  String get decreaseTarget;

  /// Section label of the weekday picker.
  ///
  /// In en, this message translates to:
  /// **'Repeat days'**
  String get habitDaysLabel;

  /// Summary under the weekday picker when all seven days are selected.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get daysEveryDay;

  /// Validation error when no weekday is selected.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day'**
  String get habitDaysError;

  /// Notice shown when editing a habit's days: the new schedule applies to the whole history.
  ///
  /// In en, this message translates to:
  /// **'Changing the days also changes how past days count toward your streak.'**
  String get scheduleChangeWarning;

  /// Button that saves the habit form.
  ///
  /// In en, this message translates to:
  /// **'Save Habit'**
  String get saveHabit;

  /// Screen-reader label of the save button while saving.
  ///
  /// In en, this message translates to:
  /// **'Saving'**
  String get savingHabit;

  /// Button on the edit screen that deletes the habit.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get deleteHabit;

  /// Title of the delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteHabitTitle(String name);

  /// Body of the delete confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Its streak and all its history will be deleted. This can\'t be undone.'**
  String get deleteHabitMessage;

  /// Confirm button of the delete dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteHabitConfirm;

  /// Dialog button that dismisses it without doing anything.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Title of the dialog shown when leaving the form with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard changes?'**
  String get discardChangesTitle;

  /// Body of the discard-changes dialog.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes.'**
  String get discardChangesMessage;

  /// Confirm button of the discard-changes dialog.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discardChangesConfirm;

  /// Button of the discard-changes dialog that stays on the form.
  ///
  /// In en, this message translates to:
  /// **'Keep editing'**
  String get keepEditing;

  /// SnackBar after a new habit is saved.
  ///
  /// In en, this message translates to:
  /// **'Habit added'**
  String get habitAdded;

  /// SnackBar after an edited habit is saved.
  ///
  /// In en, this message translates to:
  /// **'Changes saved'**
  String get habitSaved;

  /// SnackBar after a habit is deleted.
  ///
  /// In en, this message translates to:
  /// **'Habit deleted'**
  String get habitDeleted;

  /// Error state title when the habit being edited no longer exists.
  ///
  /// In en, this message translates to:
  /// **'This habit is gone'**
  String get habitNotFoundTitle;

  /// Error state message when the habit being edited no longer exists.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted.'**
  String get habitNotFoundMessage;

  /// Button that closes the screen and returns to the previous one.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// Name of the water habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get iconNameWater;

  /// Name of the running habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get iconNameRun;

  /// Name of the walking habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get iconNameWalk;

  /// Name of the cycling habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get iconNameBike;

  /// Name of the workout habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get iconNameWorkout;

  /// Name of the swimming habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get iconNameSwim;

  /// Name of the yoga habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get iconNameYoga;

  /// Name of the reading habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get iconNameBook;

  /// Name of the quran habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get iconNameQuran;

  /// Name of the prayer habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get iconNamePray;

  /// Name of the writing habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get iconNameWrite;

  /// Name of the study habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get iconNameStudy;

  /// Name of the coding habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Coding'**
  String get iconNameCode;

  /// Name of the music habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get iconNameMusic;

  /// Name of the art habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get iconNameArt;

  /// Name of the sleep habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get iconNameSleep;

  /// Name of the wake up habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Wake up'**
  String get iconNameWake;

  /// Name of the meditation habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Meditation'**
  String get iconNameMeditate;

  /// Name of the meal habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get iconNameMeal;

  /// Name of the coffee habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get iconNameCoffee;

  /// Name of the healthy eating habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Healthy eating'**
  String get iconNameFruit;

  /// Name of the medicine habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Medicine'**
  String get iconNameMedicine;

  /// Name of the savings habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get iconNameSavings;

  /// Name of the cleaning habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get iconNameClean;

  /// Name of the pet habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Pet'**
  String get iconNamePet;

  /// Name of the nature habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get iconNameNature;

  /// Name of the phone habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get iconNamePhone;

  /// Name of the no smoking habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'No smoking'**
  String get iconNameNoSmoking;

  /// Name of the heart habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Heart'**
  String get iconNameHeart;

  /// Name of the star habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Star'**
  String get iconNameStar;

  /// Name of the language habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get iconNameLanguage;

  /// Name of the family habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get iconNameFamily;

  /// Name of the call habit icon, read by screen readers in the icon picker.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get iconNameCall;

  /// Label of the form field that opens the icon and color pickers.
  ///
  /// In en, this message translates to:
  /// **'Icon and color'**
  String get habitAppearanceLabel;

  /// Button that closes the icon and color sheet.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Checkbox-like button that selects or clears all seven repeat days.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAllDays;

  /// Button on Today that opens the list of every habit.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// Title of the screen that lists every habit.
  ///
  /// In en, this message translates to:
  /// **'All habits'**
  String get allHabitsTitle;
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
