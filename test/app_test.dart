import 'package:bloc_test/bloc_test.dart';
import 'package:evolo/app.dart';
import 'package:evolo/core/di/injection.dart';
import 'package:evolo/core/router/route_error_page.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/dev/new_habit_placeholder_page.dart';
import 'package:evolo/dev/theme_showcase_page.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/presentation/cubit/today_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:evolo/features/habits/presentation/pages/today_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:material_ui/material_ui.dart';

class MockTodayCubit extends MockCubit<TodayState> implements TodayCubit;

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
    expect(find.text('اليوم'), findsOneWidget);
    expect(direction(tester), TextDirection.rtl);
  });

  testWidgets('language toggle flips direction and text', (tester) async {
    await pumpApp(tester);

    await openDevMenu(tester);
    await tester.tap(find.text('Switch language'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
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
    await tester.pumpAndSettle();
    expect(find.byType(NewHabitPlaceholderPage), findsOneWidget);

    getIt<GoRouter>().pop();
    await tester.pumpAndSettle();
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
