import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';

/// Localized screen-reader name of a habit icon key.
///
/// Keep in step with `HabitIcons`: a test checks that every key has a name.
/// An unknown key falls back to the key itself (it should never reach users).
String habitIconName(AppLocalizations l10n, String key) => switch (key) {
  'water' => l10n.iconNameWater,
  'run' => l10n.iconNameRun,
  'walk' => l10n.iconNameWalk,
  'bike' => l10n.iconNameBike,
  'workout' => l10n.iconNameWorkout,
  'swim' => l10n.iconNameSwim,
  'yoga' => l10n.iconNameYoga,
  'book' => l10n.iconNameBook,
  'quran' => l10n.iconNameQuran,
  'pray' => l10n.iconNamePray,
  'write' => l10n.iconNameWrite,
  'study' => l10n.iconNameStudy,
  'code' => l10n.iconNameCode,
  'music' => l10n.iconNameMusic,
  'art' => l10n.iconNameArt,
  'sleep' => l10n.iconNameSleep,
  'wake' => l10n.iconNameWake,
  'meditate' => l10n.iconNameMeditate,
  'meal' => l10n.iconNameMeal,
  'coffee' => l10n.iconNameCoffee,
  'fruit' => l10n.iconNameFruit,
  'medicine' => l10n.iconNameMedicine,
  'savings' => l10n.iconNameSavings,
  'clean' => l10n.iconNameClean,
  'pet' => l10n.iconNamePet,
  'nature' => l10n.iconNameNature,
  'phone' => l10n.iconNamePhone,
  'no_smoking' => l10n.iconNameNoSmoking,
  'heart' => l10n.iconNameHeart,
  'star' => l10n.iconNameStar,
  'language' => l10n.iconNameLanguage,
  'family' => l10n.iconNameFamily,
  'call' => l10n.iconNameCall,
  _ => key,
};

/// Localized name of a habit color. Exhaustive: a new [HabitColor] will not
/// compile until it has a name.
String habitColorName(AppLocalizations l10n, HabitColor color) =>
    switch (color) {
      HabitColor.orange => l10n.colorOrange,
      HabitColor.green => l10n.colorGreen,
      HabitColor.pink => l10n.colorPink,
    };
