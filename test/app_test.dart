import 'package:bloc_test/bloc_test.dart';
import 'package:evolo/app.dart';
import 'package:evolo/core/di/injection.dart';
import 'package:evolo/core/l10n/l10n.dart';
import 'package:evolo/core/router/route_error_page.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/dev/theme_showcase_page.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:evolo/features/habits/presentation/pages/habit_form_page.dart';
import 'package:evolo/features/habits/presentation/pages/today_page.dart';
import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

class MockTodayCubit extends MockCubit<TodayState> implements TodayCubit;
class MockHabitRepository extends Mock implements HabitRepository;

/// The shell of the app: language, direction, routes. The Today page's own
/// behavior is covered in `today_page_test.dart`; here it gets a fake cubit so
/// no real database is opened.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
    await initializeDateFormatting('en');
  });

  setUp(() async {
    await getIt.reset();
    await configureDependencies();
    // Same registration as production, but the cubit is a stub that shows the
    // "no habits" state (it has no endless spinner, so pumpAndSettle ends).
    await getIt.unregister<TodayCubit>();
    getIt.registerFactory<TodayCubit>(() {
      final today = CalendarDay.fromDateTime(DateTime.now());
      final cubit = MockTodayCubit();
      whenListen(
        cubit,
        const Stream<TodayState>.empty(),
        initialState: TodayState(
          today: today,
          selectedDay: today,
          weekStart: Weekday.saturday,
          status: TodayStatus.success,
        ),
      );
      return cubit;
    });
    // The form must not reach the real database either: in a widget test it
    // never answers and the test hangs. Adding a habit calls nothing on the
    // repository until Save, so a bare mock is enough.
    await getIt.unregister<HabitFormCubit>();
    getIt.registerFactoryParam<HabitFormCubit, String?, void>(
      (habitId, _) => HabitFormCubit(
        MockHabitRepository(),
        habitId: habitId,
        defaultIconKey: HabitIcons.keys.first,
      ),
    );
  });

  tearDown(getIt.reset);

  Future<void> pumpApp(WidgetTester tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('ar');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(const EvoloApp());
    await tester.pumpAndSettle();
  }

  TextDirection direction(WidgetTester tester) =>
      Directionality.of(tester.element(find.byType(Scaffold)));

  Future<void> openDevMenu(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
  }

  testWidgets('starts on Today in Arabic (RTL)', (tester) async {
    await pumpApp(tester);

    expect(find.byType(TodayPage), findsOneWidget);
    // The greeting depends on the real clock, so check a fixed text.
    final arabic = lookupAppLocalizations(const Locale('ar'));
    expect(find.text(arabic.emptyNoHabitsTitle), findsOneWidget);
    expect(direction(tester), TextDirection.rtl);
  });

  testWidgets('language toggle flips direction and text', (tester) async {
    await pumpApp(tester);

    await openDevMenu(tester);
    await tester.tap(find.text('Switch language'));
    await tester.pumpAndSettle();

    final english = lookupAppLocalizations(const Locale('en'));
    expect(find.text(english.emptyNoHabitsTitle), findsOneWidget);
    expect(direction(tester), TextDirection.ltr);
  });

  testWidgets('opens Theme Showcase and comes back', (tester) async {
    await pumpApp(tester);

    await openDevMenu(tester);
    await tester.tap(find.text('Theme showcase'));
    await tester.pumpAndSettle();
    expect(find.byType(ThemeShowcasePage), findsOneWidget);

    getIt<GoRouter>().pop();
    await tester.pumpAndSettle();
    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('the FAB opens the new-habit screen and back returns', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    // Not pumpAndSettle: the name field is focused and its caret blinks
    // forever, so the tree never "settles".
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(HabitFormPage), findsOneWidget);

    getIt<GoRouter>().pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('unknown route shows localized error page', (tester) async {
    await pumpApp(tester);

    getIt<GoRouter>().go('/nope');
    await tester.pumpAndSettle();
    expect(find.byType(RouteErrorPage), findsOneWidget);
    expect(find.text('الصفحة غير موجودة'), findsOneWidget);

    await tester.tap(find.text('العودة للرئيسية'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayPage), findsOneWidget);
  });
}
