import 'package:material_ui/material_ui.dart';

/// Maps the `iconKey` stored with a habit to a Material icon.
///
/// The DB stores the *key*, never an `IconData` / code point: a code point
/// from a non-const `IconData` breaks icon tree-shaking in Release, and a
/// key survives a Flutter upgrade that renumbers icons.
///
/// RULES for editing this file:
/// - Never rename or delete a key: it is saved in users' databases. A
///   removed key silently falls back to [fallback] (the habit still works).
/// - Add new keys at the end, lowercase with no spaces.
/// - Every value must be a `const` icon from `Icons`, so the map stays const
///   and unused icons are still tree-shaken.
abstract final class HabitIcons {
  /// Shown when a stored key is unknown (removed, or written by a newer app).
  static const IconData fallback = Icons.check_circle_outline;

  static const Map<String, IconData> _byKey = {
    'water': Icons.water_drop_outlined,
    'run': Icons.directions_run,
    'walk': Icons.directions_walk,
    'bike': Icons.directions_bike,
    'workout': Icons.fitness_center,
    'swim': Icons.pool,
    'yoga': Icons.self_improvement,
    'book': Icons.menu_book_outlined,
    'quran': Icons.auto_stories_outlined,
    'pray': Icons.mosque_outlined,
    'write': Icons.edit_note,
    'study': Icons.school_outlined,
    'code': Icons.code,
    'music': Icons.music_note_outlined,
    'art': Icons.brush_outlined,
    'sleep': Icons.bedtime_outlined,
    'wake': Icons.wb_sunny_outlined,
    'meditate': Icons.spa_outlined,
    'meal': Icons.restaurant_outlined,
    'coffee': Icons.local_cafe_outlined,
    'fruit': Icons.eco_outlined,
    'medicine': Icons.medication_outlined,
    'savings': Icons.savings_outlined,
    'clean': Icons.cleaning_services_outlined,
    'pet': Icons.pets_outlined,
    'nature': Icons.park_outlined,
    'phone': Icons.smartphone_outlined,
    'no_smoking': Icons.smoke_free_outlined,
    'heart': Icons.favorite_border,
    'star': Icons.star_border,
    'language': Icons.translate,
    'family': Icons.groups_outlined,
    'call': Icons.call_outlined,
  };

  /// Every key, in display order (the S7 icon picker shows them in this order).
  static List<String> get keys => _byKey.keys.toList(growable: false);

  /// The icon for [key], or [fallback] when the key is unknown.
  static IconData resolve(String key) => _byKey[key] ?? fallback;

  /// Whether [key] is a known key (the S7 form validates against this).
  static bool isKnown(String key) => _byKey.containsKey(key);
}
