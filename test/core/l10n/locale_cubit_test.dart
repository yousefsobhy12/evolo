import 'package:bloc_test/bloc_test.dart';
import 'package:evolo/core/l10n/locale_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolve', () {
    test('keeps supported languages, drops country', () {
      expect(LocaleCubit.resolve(const Locale('ar', 'EG')), const Locale('ar'));
      expect(LocaleCubit.resolve(const Locale('en', 'US')), const Locale('en'));
    });

    test('falls back to Arabic for unsupported languages', () {
      expect(LocaleCubit.resolve(const Locale('fr')), const Locale('ar'));
    });
  });

  group('LocaleCubit', () {
    blocTest<LocaleCubit, Locale>(
      'toggle ar -> en',
      build: () => LocaleCubit(initial: const Locale('ar')),
      act: (cubit) => cubit.toggle(),
      expect: () => [const Locale('en')],
    );

    blocTest<LocaleCubit, Locale>(
      'toggle twice returns to ar',
      build: () => LocaleCubit(initial: const Locale('ar')),
      act: (cubit) => cubit
        ..toggle()
        ..toggle(),
      expect: () => [const Locale('en'), const Locale('ar')],
    );

    blocTest<LocaleCubit, Locale>(
      'setLocale ignores unsupported locale',
      build: () => LocaleCubit(initial: const Locale('ar')),
      act: (cubit) => cubit.setLocale(const Locale('fr')),
      expect: () => <Locale>[],
    );

    blocTest<LocaleCubit, Locale>(
      'setLocale with the same locale emits nothing',
      build: () => LocaleCubit(initial: const Locale('ar')),
      act: (cubit) => cubit.setLocale(const Locale('ar')),
      expect: () => <Locale>[],
    );
  });
}
