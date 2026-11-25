import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:evolo/features/habits/presentation/utils/habit_labels.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  for (final locale in const [Locale('en'), Locale('ar')]) {
    final code = locale.languageCode;

    test('every icon key has its own name in $code', () async {
      final l10n = await AppLocalizations.delegate.load(locale);

      final names = <String>{};
      for (final key in HabitIcons.keys) {
        final name = habitIconName(l10n, key);
        expect(name, isNotEmpty, reason: key);
        expect(name, isNot(key), reason: '"$key" has no localized name');
        names.add(name);
      }
      expect(names, hasLength(HabitIcons.keys.length));
    });

    test('every color has a name in $code', () async {
      final l10n = await AppLocalizations.delegate.load(locale);

      for (final color in HabitColor.values) {
        expect(habitColorName(l10n, color), isNotEmpty, reason: color.name);
      }
    });
  }
}
