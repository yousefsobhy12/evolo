import 'package:bloc_test/bloc_test.dart';
import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/widgets/circle_icon_button.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/presentation/cubit/all_habits_cubit.dart';
import 'package:evolo/features/habits/presentation/cubit/all_habits_state.dart';
import 'package:evolo/features/habits/presentation/pages/all_habits_page.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_summary_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class MockAllHabitsCubit extends MockCubit<AllHabitsState>
    implements AllHabitsCubit;

void main() {
  Habit habit(String id, String name, {Set<Weekday>? days, int target = 1}) {
    return Habit(
      id: id,
      name: name,
      iconKey: 'book',
      color: HabitColor.green,
      dailyTarget: target,
      schedule: days == null ? HabitSchedule.everyDay() : HabitSchedule(days),
      createdAt: DateTime(2026, 11),
    );
  }

  final habits = [
    habit('h1', 'Read'),
    habit(
      'h2',
      'Morning walk',
      days: {Weekday.monday, Weekday.saturday},
      target: 3,
    ),
  ];

  late MockAllHabitsCubit cubit;

  setUpAll(initializeTestLocales);

  setUp(() {
    cubit = MockAllHabitsCubit();
    when(() => cubit.retry()).thenAnswer((_) async {});
  });

  /// Pushed over a stub home, so the close button has somewhere to go.
  Future<void> pump(
    WidgetTester tester,
    AllHabitsState state, {
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) async {
    whenListen(
      cubit,
      const Stream<AllHabitsState>.empty(),
      initialState: state,
    );
    Widget stub(String text) => Scaffold(body: Text(text));
    final router = GoRouter(
      routes: [
        GoRoute(path: AppRoutes.today, builder: (_, _) => stub('home')),
        GoRoute(
          path: AppRoutes.allHabits,
          builder: (_, _) => BlocProvider<AllHabitsCubit>.value(
            value: cubit,
            child: const AllHabitsPage(),
          ),
        ),
        GoRoute(path: AppRoutes.newHabit, builder: (_, _) => stub('new')),
        GoRoute(
          path: AppRoutes.editHabitPattern,
          builder: (_, state) => stub('edit ${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await pumpApp(
      tester,
      router: router,
      locale: locale,
      brightness: brightness,
      textScale: textScale,
    );
    router.push<void>(AppRoutes.allHabits).ignore();
    // Not pumpAndSettle: the loading spinner never settles.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  final loaded = AllHabitsState(
    status: AllHabitsStatus.success,
    habits: habits,
  );

  testWidgets('loading shows a spinner and the title', (tester) async {
    await pump(tester, const AllHabitsState());

    expect(find.text('All habits'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('failure can be retried', (tester) async {
    await pump(
      tester,
      const AllHabitsState(
        status: AllHabitsStatus.failure,
        failure: DatabaseFailure(),
      ),
    );

    await tester.tap(find.text('Try again'));

    verify(() => cubit.retry()).called(1);
  });

  testWidgets('no habits offers to add one', (tester) async {
    await pump(tester, const AllHabitsState(status: AllHabitsStatus.success));

    await tester.tap(find.text('Add a habit'));
    await tester.pumpAndSettle();

    expect(find.text('new'), findsOneWidget);
  });

  testWidgets('lists every habit with its days and goal', (tester) async {
    await pump(tester, loaded);

    expect(find.byType(HabitSummaryCard), findsNWidgets(2));
    expect(find.text('Every day'), findsOneWidget);
    // Saturday first, whatever the order in the set.
    expect(find.text('Sat, Mon'), findsOneWidget);
    expect(find.text('3 times a day'), findsOneWidget);
  });

  testWidgets('pressing a habit opens it for editing', (tester) async {
    await pump(tester, loaded);

    await tester.tap(find.text('Morning walk'));
    await tester.pumpAndSettle();

    expect(find.text('edit h2'), findsOneWidget);
  });

  testWidgets('the close button goes back', (tester) async {
    await pump(tester, loaded);

    await tester.tap(find.byType(CircleIconButton));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(find.byType(AllHabitsPage), findsNothing);
  });

  for (final (locale, brightness, scale) in const [
    (Locale('en'), Brightness.light, 1.0),
    (Locale('ar'), Brightness.dark, 1.5),
  ]) {
    testWidgets(
      'fits 360 wide, ${locale.languageCode} ${brightness.name} x$scale',
      (tester) async {
        await pump(
          tester,
          AllHabitsState(
            status: AllHabitsStatus.success,
            habits: [
              habit(
                'h1',
                'Drink a full glass of water before every single meal',
                days: Weekday.values.toSet()..remove(Weekday.friday),
                target: 99,
              ),
            ],
          ),
          locale: locale,
          brightness: brightness,
          textScale: scale,
        );

        expect(tester.takeException(), isNull);
      },
    );
  }
}
