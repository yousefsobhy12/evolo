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
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

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

  @override
  String get newHabitTitle => 'New habit';

  @override
  String get editHabitTitle => 'Edit habit';

  @override
  String get habitNameLabel => 'Name';

  @override
  String get habitNameHint => 'e.g. Drink water';

  @override
  String habitNameCounter(int count, int max) {
    return '$count/$max';
  }

  @override
  String get habitNameEmptyError => 'Give your habit a name';

  @override
  String habitNameTooLongError(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Up to $max characters',
      one: 'Up to 1 character',
    );
    return '$_temp0';
  }

  @override
  String get habitIconLabel => 'Icon';

  @override
  String get habitColorLabel => 'Color';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorPink => 'Pink';

  @override
  String get habitTargetLabel => 'Set a goal';

  @override
  String habitTargetSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times a day',
      two: 'Twice a day',
      one: 'Once a day',
    );
    return '$_temp0';
  }

  @override
  String get increaseTarget => 'Increase goal';

  @override
  String get decreaseTarget => 'Decrease goal';

  @override
  String get habitDaysLabel => 'Repeat days';

  @override
  String get daysEveryDay => 'Every day';

  @override
  String get habitDaysError => 'Pick at least one day';

  @override
  String get scheduleChangeWarning =>
      'Changing the days also changes how past days count toward your streak.';

  @override
  String get saveHabit => 'Save Habit';

  @override
  String get savingHabit => 'Saving';

  @override
  String get deleteHabit => 'Delete habit';

  @override
  String deleteHabitTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteHabitMessage =>
      'Its streak and all its history will be deleted. This can\'t be undone.';

  @override
  String get deleteHabitConfirm => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage => 'You have unsaved changes.';

  @override
  String get discardChangesConfirm => 'Discard';

  @override
  String get keepEditing => 'Keep editing';

  @override
  String get habitAdded => 'Habit added';

  @override
  String get habitSaved => 'Changes saved';

  @override
  String get habitDeleted => 'Habit deleted';

  @override
  String get habitNotFoundTitle => 'This habit is gone';

  @override
  String get habitNotFoundMessage => 'It may have been deleted.';

  @override
  String get goBack => 'Go back';

  @override
  String get iconNameWater => 'Water';

  @override
  String get iconNameRun => 'Running';

  @override
  String get iconNameWalk => 'Walking';

  @override
  String get iconNameBike => 'Cycling';

  @override
  String get iconNameWorkout => 'Workout';

  @override
  String get iconNameSwim => 'Swimming';

  @override
  String get iconNameYoga => 'Yoga';

  @override
  String get iconNameBook => 'Reading';

  @override
  String get iconNameQuran => 'Quran';

  @override
  String get iconNamePray => 'Prayer';

  @override
  String get iconNameWrite => 'Writing';

  @override
  String get iconNameStudy => 'Study';

  @override
  String get iconNameCode => 'Coding';

  @override
  String get iconNameMusic => 'Music';

  @override
  String get iconNameArt => 'Art';

  @override
  String get iconNameSleep => 'Sleep';

  @override
  String get iconNameWake => 'Wake up';

  @override
  String get iconNameMeditate => 'Meditation';

  @override
  String get iconNameMeal => 'Meal';

  @override
  String get iconNameCoffee => 'Coffee';

  @override
  String get iconNameFruit => 'Healthy eating';

  @override
  String get iconNameMedicine => 'Medicine';

  @override
  String get iconNameSavings => 'Savings';

  @override
  String get iconNameClean => 'Cleaning';

  @override
  String get iconNamePet => 'Pet';

  @override
  String get iconNameNature => 'Nature';

  @override
  String get iconNamePhone => 'Phone';

  @override
  String get iconNameNoSmoking => 'No smoking';

  @override
  String get iconNameHeart => 'Heart';

  @override
  String get iconNameStar => 'Star';

  @override
  String get iconNameLanguage => 'Language';

  @override
  String get iconNameFamily => 'Family';

  @override
  String get iconNameCall => 'Call';

  @override
  String get habitAppearanceLabel => 'Icon and color';

  @override
  String get done => 'Done';

  @override
  String get selectAllDays => 'Select all';

  @override
  String get seeAll => 'See all';

  @override
  String get allHabitsTitle => 'All habits';
}
