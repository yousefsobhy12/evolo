import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:evolo/features/habits/presentation/cubit/today_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:evolo/features/habits/presentation/pages/today_page.dart';
import 'package:evolo/features/habits/presentation/widgets/day_strip.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_check_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/habit_fixtures.dart';
import '../../../../helpers/pump_app.dart';

class MockTodayCubit extends MockCubit<TodayState> implements TodayCubit;

void main() {
  // Sunday 2026-11-22, strip Nov 21 .. Nov 27.
  final today = CalendarDay(2026, 11, 22);
  CalendarDay nov(int day) => CalendarDay(2026, 11, day);

  TodayState stateOf({
    TodayStatus status = TodayStatus.success,
    List<TodayItem> items = const [],
    bool hasAnyHabit = true,
    CalendarDay? selectedDay,
    Failure? failure,
    Failure? actionFailure,
  }) {
    return TodayState(
      today: today,
      selectedDay: selectedDay ?? today,
      weekStart: Weekday.saturday,
      firstSelectableDay: nov(1),
      status: status,
      items: items,
      hasAnyHabit: hasAnyHabit,
      failure: failure,
      actionFailure: actionFailure,
    );
  }

  final water = todayItem(count: 3, target: 8, streak: 4);
  final read = todayItem(id: 'h2', name: 'Read', streak: 12, atRisk: true);

  late MockTodayCubit cubit;
  // The greeting reads this clock on every build.
  late DateTime clock;
  setUpAll(() async {
    await initializeTestLocales();
    registerFallbackValue(today);
    registerFallbackValue(water);
  });

  setUp(() {
    clock = DateTime(2026, 11, 22, 9);
    cubit = MockTodayCubit();
    when(() => cubit.tapCheck(any())).thenAnswer((_) async {});
    when(() => cubit.decrement(any())).thenAnswer((_) async {});
    when(() => cubit.retry()).thenAnswer((_) async {});
  });

  GoRouter routerFor(TodayCubit cubit) {
    return GoRouter(
      routes: [
        GoRoute(
          path: AppRoutes.today,
          builder: (context, state) => BlocProvider<TodayCubit>.value(
            value: cubit,
            child: TodayPage(now: () => clock),
          ),
        ),
        GoRoute(
          path: AppRoutes.allHabits,
          builder: (context, state) => const Scaffold(body: Text('all habits')),
        ),
        GoRoute(
          path: AppRoutes.newHabit,
          builder: (context, state) => const _FormStub(),
        ),
        GoRoute(
          path: AppRoutes.editHabitPattern,
          builder: (context, state) =>
              _FormStub(habitId: state.pathParameters['id']),
        ),
      ],
    );
  }

  Future<void> pump(
    WidgetTester tester,
    TodayState state, {
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) {
    whenListen(cubit, const Stream<TodayState>.empty(), initialState: state);
    return pumpApp(
      tester,
      router: routerFor(cubit),
      locale: locale,
      brightness: brightness,
      textScale: textScale,
    );
  }

  group('the four states', () {
    testWidgets('loading shows a spinner under the day strip', (tester) async {
      await pump(tester, stateOf(status: TodayStatus.loading));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
    });

    testWidgets('failure shows the error and Try again retries', (
      tester,
    ) async {
      await pump(
        tester,
        stateOf(status: TodayStatus.failure, failure: const DatabaseFailure()),
      );

      expect(find.textContaining('load your habits'), findsOneWidget);

      await tester.tap(find.text('Try again'));

      verify(() => cubit.retry()).called(1);
    });

    testWidgets('no habits at all invites the user to add one', (tester) async {
      await pump(tester, stateOf(hasAnyHabit: false));

      expect(find.text('Start your first habit'), findsOneWidget);

      await tester.tap(find.text('Add a habit'));
      await tester.pumpAndSettle();

      expect(find.byType(_FormStub), findsOneWidget);
    });

    testWidgets('a day with nothing due says it is a rest day', (tester) async {
      await pump(tester, stateOf());

      expect(find.text('A rest day'), findsOneWidget);
      expect(find.text('Add a habit'), findsNothing);
    });

    testWidgets('data shows the heading and one card per habit', (
      tester,
    ) async {
      await pump(tester, stateOf(items: [water, read]));

      expect(find.text('Daily routine'), findsOneWidget);
      expect(find.text('Drink water'), findsOneWidget);
      expect(find.text('Read'), findsOneWidget);
    });
  });

  group('the header', () {
    testWidgets('greets by the time of day and shows the date', (tester) async {
      await pump(tester, stateOf(items: [read]));

      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('Sunday, November 22'), findsOneWidget);
    });

    testWidgets('the date follows the selected day', (tester) async {
      await pump(tester, stateOf(items: [read], selectedDay: nov(21)));

      expect(find.text('Saturday, November 21'), findsOneWidget);
    });

    testWidgets('the greeting is refreshed when the app returns', (
      tester,
    ) async {
      await pump(tester, stateOf(items: [read]));
      clock = DateTime(2026, 11, 22, 20);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(find.text('Good evening'), findsOneWidget);
    });
  });

  group('completing habits', () {
    testWidgets('a tap on the circle goes to the cubit with its item', (
      tester,
    ) async {
      await pump(tester, stateOf(items: [water, read]));

      await tester.tap(find.byType(HabitCheckButton).last);

      verify(() => cubit.tapCheck(read)).called(1);
    });

    testWidgets('the minus goes to the cubit with its item', (tester) async {
      await pump(tester, stateOf(items: [water, read]));

      await tester.tap(find.byIcon(Icons.remove));

      verify(() => cubit.decrement(water)).called(1);
    });

    testWidgets('a failed action shows a SnackBar once and is dismissed', (
      tester,
    ) async {
      final controller = StreamController<TodayState>();
      addTearDown(controller.close);
      final base = stateOf(items: [read]);
      whenListen(cubit, controller.stream, initialState: base);
      await pumpApp(tester, router: routerFor(cubit));

      controller.add(
        stateOf(items: [read], actionFailure: const DatabaseFailure()),
      );
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('save that change'), findsOneWidget);
      verify(() => cubit.dismissActionFailure()).called(1);
    });
  });

  group('the day strip and the week', () {
    testWidgets('tapping a day asks the cubit to open it', (tester) async {
      await pump(tester, stateOf(items: [read]));

      await tester.tap(find.text('21'));

      verify(() => cubit.selectDay(nov(21))).called(1);
    });

    testWidgets('swiping the strip goes to the cubit', (tester) async {
      await pump(tester, stateOf(items: [read]));

      await tester.fling(find.byType(DayStrip), const Offset(200, 0), 1000);
      await tester.pumpAndSettle();

      verify(() => cubit.previousWeek()).called(1);
    });

    testWidgets('Back to today is hidden on today', (tester) async {
      await pump(tester, stateOf(items: [read]));

      expect(find.text('Back to today'), findsNothing);
    });

    testWidgets('Back to today shows on another day and returns', (
      tester,
    ) async {
      await pump(tester, stateOf(items: [read], selectedDay: nov(21)));

      await tester.tap(find.text('Back to today'));

      verify(() => cubit.goToToday()).called(1);
    });
  });

  group('the app lifecycle and the FAB', () {
    testWidgets('returning to the app refreshes today', (tester) async {
      await pump(tester, stateOf(items: [read]));

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

      verify(() => cubit.refreshToday()).called(1);
    });

    testWidgets('the FAB opens the new-habit screen', (tester) async {
      await pump(tester, stateOf(items: [read]));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(_FormStub), findsOneWidget);
    });

    testWidgets('tapping the body of a card opens that habit for editing', (
      tester,
    ) async {
      await pump(tester, stateOf(items: [water, read]));

      await tester.tap(find.text('Read'));
      await tester.pumpAndSettle();

      final stub = tester.widget<_FormStub>(find.byType(_FormStub));
      expect(stub.habitId, 'h2');
      verifyNever(() => cubit.tapCheck(any()));
    });
  });

  group('See all', () {
    testWidgets('next to the heading opens every habit', (tester) async {
      await pump(tester, stateOf(items: [read]));

      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();

      expect(find.text('all habits'), findsOneWidget);
    });

    testWidgets('is also there on a rest day', (tester) async {
      await pump(tester, stateOf());

      await tester.tap(find.text('See all'));
      await tester.pumpAndSettle();

      expect(find.text('all habits'), findsOneWidget);
    });

    testWidgets('is hidden when there are no habits at all', (tester) async {
      await pump(tester, stateOf(hasAnyHabit: false));

      expect(find.text('See all'), findsNothing);
    });
  });

  group('the whole page scrolls', () {
    testWidgets('the header leaves the screen with the list', (tester) async {
      final many = [
        for (var i = 0; i < 12; i++) todayItem(id: 'h$i', name: 'Habit $i'),
      ];
      await pump(tester, stateOf(items: many));
      final before = tester.getTopLeft(find.text('Good morning')).dy;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -80));
      await tester.pump();

      expect(tester.getTopLeft(find.text('Good morning')).dy, lessThan(before));
    });

    testWidgets('on a short screen the empty action is reachable', (
      tester,
    ) async {
      whenListen(
        cubit,
        const Stream<TodayState>.empty(),
        initialState: stateOf(hasAnyHabit: false),
      );
      await pumpApp(
        tester,
        router: routerFor(cubit),
        size: const Size(360, 400),
        textScale: 1.5,
      );

      await tester.scrollUntilVisible(
        find.text('Add a habit'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add a habit'));
      await tester.pumpAndSettle();

      expect(find.byType(_FormStub), findsOneWidget);
    });

    testWidgets('a wide screen shows the empty state without overflow', (
      tester,
    ) async {
      whenListen(
        cubit,
        const Stream<TodayState>.empty(),
        initialState: stateOf(hasAnyHabit: false),
      );
      await pumpApp(
        tester,
        router: routerFor(cubit),
        size: const Size(800, 360),
        textScale: 1.5,
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });

  group('fits a 360 wide phone without overflow', () {
    final busy = [
      water,
      read,
      todayItem(
        id: 'h3',
        name: 'Drink a full glass of water before every single meal',
        count: 8,
        target: 8,
        streak: 30,
        freezes: 2,
      ),
    ];

    for (final locale in [const Locale('en'), const Locale('ar')]) {
      for (final brightness in Brightness.values) {
        for (final scale in [1.0, 1.5]) {
          testWidgets(
            'data ${locale.languageCode} ${brightness.name} x$scale',
            (tester) async {
              await pump(
                tester,
                stateOf(items: busy),
                locale: locale,
                brightness: brightness,
                textScale: scale,
              );
              await tester.pumpAndSettle();
              expect(tester.takeException(), isNull);

              // Rows are built lazily, so scroll to the end as well.
              await tester.drag(
                find.byType(CustomScrollView),
                const Offset(0, -2000),
              );
              await tester.pumpAndSettle();

              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }

    for (final scale in [1.0, 1.5]) {
      testWidgets('the empty and error states x$scale', (tester) async {
        await pump(tester, stateOf(hasAnyHabit: false), textScale: scale);
        expect(tester.takeException(), isNull);

        await pump(
          tester,
          stateOf(
            status: TodayStatus.failure,
            failure: const DatabaseFailure(),
          ),
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });
}

/// Stands in for the real form: these tests only check that Today navigates.
class _FormStub extends StatelessWidget {
  const new({this.habitId});

  final String? habitId;

  @override
  Widget build(BuildContext context) => const Scaffold();
}
