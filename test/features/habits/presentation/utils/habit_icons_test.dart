import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Every key that has ever shipped. They live in users' databases, so the
  // registry may grow but must never lose or rename one. Add new keys here
  // when you add them to `HabitIcons`.
  const shippedKeys = [
    'water',
    'run',
    'walk',
    'bike',
    'workout',
    'swim',
    'yoga',
    'book',
    'quran',
    'pray',
    'write',
    'study',
    'code',
    'music',
    'art',
    'sleep',
    'wake',
    'meditate',
    'meal',
    'coffee',
    'fruit',
    'medicine',
    'savings',
    'clean',
    'pet',
    'nature',
    'phone',
    'no_smoking',
    'heart',
    'star',
    'language',
    'family',
    'call',
  ];

  test('no shipped key was removed or renamed', () {
    for (final key in shippedKeys) {
      expect(HabitIcons.isKnown(key), isTrue, reason: key);
    }
  });

  test('every shipped key is in the registry exactly once', () {
    expect(HabitIcons.keys, unorderedEquals(shippedKeys));
  });

  test('every key resolves to its own icon, not the fallback', () {
    for (final key in HabitIcons.keys) {
      expect(HabitIcons.resolve(key), isNot(HabitIcons.fallback), reason: key);
    }
  });

  test('no two keys share an icon (the picker would show duplicates)', () {
    final icons = HabitIcons.keys.map(HabitIcons.resolve).toSet();

    expect(icons, hasLength(HabitIcons.keys.length));
  });

  test('an unknown key falls back instead of throwing', () {
    expect(HabitIcons.resolve('does_not_exist'), HabitIcons.fallback);
    expect(HabitIcons.resolve(''), HabitIcons.fallback);
    expect(HabitIcons.isKnown('does_not_exist'), isFalse);
  });

  test('keys are lowercase snake_case', () {
    final pattern = RegExp(r'^[a-z][a-z_]*$');

    for (final key in HabitIcons.keys) {
      expect(pattern.hasMatch(key), isTrue, reason: key);
    }
  });
}
