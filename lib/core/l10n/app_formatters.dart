import 'package:evolo/core/l10n/digit_style.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Single place that turns numbers/dates into display strings.
///
/// Digits are pinned explicitly instead of relying on intl's default for
/// 'ar', which can differ between intl versions and regions.
class AppFormatters {
  const new({required this.locale, this.digitStyle = DigitStyle.latin});

  final Locale locale;
  final DigitStyle digitStyle;

  static const _latin = '0123456789';
  static const _arabicIndic = '٠١٢٣٤٥٦٧٨٩';

  bool get _useArabicIndic =>
      digitStyle == DigitStyle.arabicIndic && locale.languageCode == 'ar';

  // 'en' symbols => deterministic Latin digits and separators.
  // 'ar_EG' => Arabic-Indic digits and Arabic separators.
  String get _numberLocale => _useArabicIndic ? 'ar_EG' : 'en';

  String number(num value, {int? fractionDigits}) {
    final format = fractionDigits == null
        ? NumberFormat.decimalPattern(_numberLocale)
        : NumberFormat.decimalPatternDigits(
            locale: _numberLocale,
            decimalDigits: fractionDigits,
          );
    return digits(format.format(value));
  }

  /// [ratio] is 0..1 (0.5 => 50%).
  String percent(double ratio) =>
      digits(NumberFormat.percentPattern(_numberLocale).format(ratio));

  // Dates use the language code ('ar'/'en') so month names are localized.
  // Needs initializeDateFormatting() at startup.
  String dateMedium(DateTime date) =>
      digits(DateFormat.yMMMd(locale.languageCode).format(date));

  String time(DateTime date) =>
      digits(DateFormat.jm(locale.languageCode).format(date));

  /// One-letter weekday for the day strip (Arabic: ح ن ث ر خ ج س).
  /// Several English days share a letter (S, T), so the strip also shows the
  /// day number and its screen-reader label uses [fullDate].
  String weekdayNarrow(DateTime date) =>
      DateFormat.EEEEE(locale.languageCode).format(date);

  /// Full weekday name: "Saturday". Screen-reader label of the weekday picker.
  String weekdayFull(DateTime date) =>
      DateFormat.EEEE(locale.languageCode).format(date);

  /// Short weekday name: "Sat" / "سبت". For the schedule summary.
  String weekdayShort(DateTime date) =>
      DateFormat.E(locale.languageCode).format(date);

  /// Weekday, month and day: "Sunday, November 22".
  String fullDate(DateTime date) =>
      digits(DateFormat.MMMMEEEEd(locale.languageCode).format(date));

  /// Converts every digit in [input] to the active digit set.
  ///
  /// Only for app-generated strings. Never pass user-entered text
  /// (e.g. a habit name), it would silently change what the user typed.
  String digits(String input) {
    final (from, to) = _useArabicIndic
        ? (_latin, _arabicIndic)
        : (_arabicIndic, _latin);
    final out = StringBuffer();
    for (final char in input.split('')) {
      final index = from.indexOf(char);
      out.write(index == -1 ? char : to[index]);
    }
    return out.toString();
  }
}

extension AppFormattersX on BuildContext {
  /// Digit style is fixed to Latin until the Settings screen (S11) exists.
  AppFormatters get formatters =>
      AppFormatters(locale: Localizations.localeOf(this));
}
