import 'package:evolo/core/l10n/app_formatters.dart';
import 'package:evolo/core/l10n/digit_style.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  const ar = Locale('ar');
  const en = Locale('en');

  AppFormatters build(Locale locale, [DigitStyle style = DigitStyle.latin]) =>
      AppFormatters(locale: locale, digitStyle: style);

  setUpAll(() async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en');
  });

  group('number', () {
    test('Arabic + latin keeps Latin digits and separators', () {
      expect(build(ar).number(1234.5), '1,234.5');
    });

    test('Arabic + arabicIndic uses Arabic digits and separators', () {
      expect(build(ar, DigitStyle.arabicIndic).number(1234.5), '١٬٢٣٤٫٥');
    });

    test('English ignores arabicIndic', () {
      expect(build(en, DigitStyle.arabicIndic).number(1234.5), '1,234.5');
    });

    test('fractionDigits', () {
      expect(build(ar).number(3.14159, fractionDigits: 2), '3.14');
      expect(
        build(ar, DigitStyle.arabicIndic).number(3.14159, fractionDigits: 2),
        '٣٫١٤',
      );
    });
  });

  group('digits', () {
    test('latin converts Arabic-Indic to Latin', () {
      expect(build(ar).digits('٣ أيام'), '3 أيام');
    });

    test('arabicIndic converts Latin to Arabic-Indic, text untouched', () {
      expect(
        build(ar, DigitStyle.arabicIndic).digits('Streak 3 أيام'),
        'Streak ٣ أيام',
      );
    });
  });

  group('percent / date / time', () {
    final date = DateTime(2026, 11, 19, 9, 30);

    test('percent', () {
      expect(build(ar).percent(0.5), '50%');
      expect(build(ar, DigitStyle.arabicIndic).percent(0.5), contains('٥٠'));
    });

    test('dateMedium', () {
      expect(
        build(ar).dateMedium(date),
        allOf(contains('19'), contains('2026')),
      );
      expect(
        build(ar, DigitStyle.arabicIndic).dateMedium(date),
        allOf(contains('١٩'), contains('٢٠٢٦')),
      );
    });

    test('time', () {
      expect(build(ar).time(date), contains('9:30'));
      expect(build(ar, DigitStyle.arabicIndic).time(date), contains('٩:٣٠'));
    });
  });
}
