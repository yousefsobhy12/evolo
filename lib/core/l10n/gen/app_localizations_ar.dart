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
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'مساء الخير';

  @override
  String get greetingEvening => 'مساء الخير';

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

  @override
  String get newHabitTitle => 'عادة جديدة';

  @override
  String get editHabitTitle => 'تعديل العادة';

  @override
  String get habitNameLabel => 'الاسم';

  @override
  String get habitNameHint => 'مثال: شرب الماء';

  @override
  String habitNameCounter(int count, int max) {
    return '$count/$max';
  }

  @override
  String get habitNameEmptyError => 'اكتب اسمًا للعادة';

  @override
  String habitNameTooLongError(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'الحد الأقصى $max حرف',
      many: 'الحد الأقصى $max حرفًا',
      few: 'الحد الأقصى $max أحرف',
      two: 'الحد الأقصى حرفان',
      one: 'الحد الأقصى حرف واحد',
    );
    return '$_temp0';
  }

  @override
  String get habitIconLabel => 'الأيقونة';

  @override
  String get habitColorLabel => 'اللون';

  @override
  String get colorOrange => 'برتقالي';

  @override
  String get colorGreen => 'أخضر';

  @override
  String get colorPink => 'وردي';

  @override
  String get habitTargetLabel => 'حدّد هدفك';

  @override
  String habitTargetSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مرة في اليوم',
      many: '$count مرة في اليوم',
      few: '$count مرات في اليوم',
      two: 'مرتان في اليوم',
      one: 'مرة واحدة في اليوم',
    );
    return '$_temp0';
  }

  @override
  String get increaseTarget => 'زيادة الهدف';

  @override
  String get decreaseTarget => 'إنقاص الهدف';

  @override
  String get habitDaysLabel => 'أيام التكرار';

  @override
  String get daysEveryDay => 'كل يوم';

  @override
  String get habitDaysError => 'اختر يومًا واحدًا على الأقل';

  @override
  String get scheduleChangeWarning =>
      'تغيير الأيام يغيّر أيضًا طريقة احتساب الأيام السابقة في سلسلتك.';

  @override
  String get saveHabit => 'حفظ العادة';

  @override
  String get savingHabit => 'جارٍ الحفظ';

  @override
  String get deleteHabit => 'حذف العادة';

  @override
  String deleteHabitTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String get deleteHabitMessage =>
      'ستُحذف سلسلتها وكل سجلها نهائيًا، ولا يمكن التراجع عن ذلك.';

  @override
  String get deleteHabitConfirm => 'احذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get discardChangesTitle => 'تجاهل التغييرات؟';

  @override
  String get discardChangesMessage => 'لديك تغييرات غير محفوظة.';

  @override
  String get discardChangesConfirm => 'تجاهل';

  @override
  String get keepEditing => 'متابعة التعديل';

  @override
  String get habitAdded => 'تمت إضافة العادة';

  @override
  String get habitSaved => 'تم حفظ التغييرات';

  @override
  String get habitDeleted => 'تم حذف العادة';

  @override
  String get habitNotFoundTitle => 'هذه العادة لم تعد موجودة';

  @override
  String get habitNotFoundMessage => 'ربما تم حذفها.';

  @override
  String get goBack => 'رجوع';

  @override
  String get iconNameWater => 'ماء';

  @override
  String get iconNameRun => 'الجري';

  @override
  String get iconNameWalk => 'المشي';

  @override
  String get iconNameBike => 'ركوب الدراجة';

  @override
  String get iconNameWorkout => 'تمرين';

  @override
  String get iconNameSwim => 'السباحة';

  @override
  String get iconNameYoga => 'يوغا';

  @override
  String get iconNameBook => 'القراءة';

  @override
  String get iconNameQuran => 'القرآن';

  @override
  String get iconNamePray => 'الصلاة';

  @override
  String get iconNameWrite => 'الكتابة';

  @override
  String get iconNameStudy => 'الدراسة';

  @override
  String get iconNameCode => 'البرمجة';

  @override
  String get iconNameMusic => 'الموسيقى';

  @override
  String get iconNameArt => 'الفن';

  @override
  String get iconNameSleep => 'النوم';

  @override
  String get iconNameWake => 'الاستيقاظ';

  @override
  String get iconNameMeditate => 'التأمل';

  @override
  String get iconNameMeal => 'وجبة';

  @override
  String get iconNameCoffee => 'قهوة';

  @override
  String get iconNameFruit => 'أكل صحي';

  @override
  String get iconNameMedicine => 'دواء';

  @override
  String get iconNameSavings => 'ادخار';

  @override
  String get iconNameClean => 'التنظيف';

  @override
  String get iconNamePet => 'حيوان أليف';

  @override
  String get iconNameNature => 'الطبيعة';

  @override
  String get iconNamePhone => 'الهاتف';

  @override
  String get iconNameNoSmoking => 'الإقلاع عن التدخين';

  @override
  String get iconNameHeart => 'قلب';

  @override
  String get iconNameStar => 'نجمة';

  @override
  String get iconNameLanguage => 'لغة';

  @override
  String get iconNameFamily => 'العائلة';

  @override
  String get iconNameCall => 'اتصال';

  @override
  String get habitAppearanceLabel => 'الأيقونة واللون';

  @override
  String get done => 'تم';

  @override
  String get selectAllDays => 'تحديد الكل';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get allHabitsTitle => 'كل العادات';

  @override
  String get statsTitle => 'التقدّم';

  @override
  String get statsPeriodWeek => 'هذا الأسبوع';

  @override
  String get statsPeriodMonth => 'هذا الشهر';

  @override
  String get statsCompletionRate => 'نسبة الإنجاز';

  @override
  String get statsBestStreak => 'أطول سلسلة';

  @override
  String statsBestStreakCaption(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'يوم (لكل الوقت)',
      many: 'يومًا (لكل الوقت)',
      few: 'أيام (لكل الوقت)',
      two: 'يومان (لكل الوقت)',
      one: 'يوم (لكل الوقت)',
      zero: 'أيام (لكل الوقت)',
    );
    return '$_temp0';
  }

  @override
  String get statsTotalCheckIns => 'مرات الإنجاز';

  @override
  String get statsNoCountedDays => 'لا أيام محسوبة';

  @override
  String get statsByHabitHeading => 'حسب العادة';

  @override
  String statsBarSemantics(String habit, String value) {
    return '$habit: $value';
  }
}
