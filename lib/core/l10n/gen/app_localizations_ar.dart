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

  @override
  String get todayTitle => 'اليوم';

  @override
  String get todayDailyRoutine => 'روتينك اليومي';

  @override
  String get previousWeek => 'الأسبوع السابق';

  @override
  String get nextWeek => 'الأسبوع التالي';

  @override
  String get backToToday => 'العودة إلى اليوم';

  @override
  String streakCurrent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'السلسلة: $count يوم',
      many: 'السلسلة: $count يومًا',
      few: 'السلسلة: $count أيام',
      two: 'السلسلة: يومان',
      one: 'السلسلة: يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get streakStart => 'ابدأ سلسلتك اليوم';

  @override
  String get streakAtRisk => 'في خطر';

  @override
  String streakFreezesAvailable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count تجميد متاح',
      many: '$count تجميدًا متاحًا',
      few: '$count تجميدات متاحة',
      two: 'تجميدان متاحان',
      one: 'تجميد واحد متاح',
    );
    return '$_temp0';
  }

  @override
  String habitProgressSemantics(int count, int target) {
    return 'تم $count من $target';
  }

  @override
  String completeHabit(String name) {
    return 'إنجاز $name';
  }

  @override
  String undoHabit(String name) {
    return 'التراجع عن $name';
  }

  @override
  String get addOne => 'زيادة واحد';

  @override
  String addOneTo(String name) {
    return 'إضافة واحد إلى $name';
  }

  @override
  String get removeOne => 'إنقاص واحد';

  @override
  String get addHabit => 'إضافة عادة';

  @override
  String get emptyNoHabitsTitle => 'ابدأ بأول عادة';

  @override
  String get emptyNoHabitsMessage =>
      'خطوات صغيرة كل يوم تصنع فرقًا. أنشئ عادة وابنِ سلسلتك.';

  @override
  String get emptyNoHabitsAction => 'أضف عادة';

  @override
  String get emptyNothingDueTitle => 'يوم راحة';

  @override
  String get emptyNothingDueMessage => 'لا توجد عادات مجدولة لهذا اليوم.';

  @override
  String get loadErrorTitle => 'تعذّر تحميل عاداتك';

  @override
  String get loadErrorMessage => 'حدث خطأ أثناء قراءة بياناتك. حاول مرة أخرى.';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String get actionErrorMessage => 'تعذّر حفظ التغيير. حاول مرة أخرى.';

  @override
  String get loading => 'جارٍ التحميل';

  @override
  String get reminderCardTitle => 'لا تفوّت عاداتك';

  @override
  String get reminderCardMessage => 'اختر وقتًا مناسبًا وسنذكّرك بهدوء.';

  @override
  String get reminderCardAction => 'حدّد الآن';
}
