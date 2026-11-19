// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Evolo';

  @override
  String get homeTitle => 'اليوم';

  @override
  String get homePlaceholder => 'ستظهر عاداتك هنا.';

  @override
  String get openThemeShowcase => 'فتح معرض الثيم';

  @override
  String get switchLanguage => 'تغيير اللغة';

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count يوم',
      many: '$count يومًا',
      few: '$count أيام',
      two: 'يومان',
      one: 'يوم واحد',
      zero: 'لا أيام',
    );
    return '$_temp0';
  }

  @override
  String get pageNotFoundTitle => 'الصفحة غير موجودة';

  @override
  String get pageNotFoundMessage => 'هذه الصفحة غير موجودة أو تم نقلها.';

  @override
  String get goHome => 'العودة للرئيسية';
}
