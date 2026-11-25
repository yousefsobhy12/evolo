import 'dart:async';

import 'package:evolo/core/errors/failure.dart';
import 'package:evolo/core/router/app_routes.dart';
import 'package:evolo/core/widgets/evolo_button.dart';
import 'package:evolo/features/habits/domain/entities/habit.dart';
import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/domain/repositories/habit_repository.dart';
import 'package:evolo/features/habits/presentation/cubit/habit_form_cubit.dart';
import 'package:evolo/features/habits/presentation/pages/habit_form_page.dart';
import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:evolo/features/habits/presentation/widgets/weekday_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class MockHabitRepository extends Mock implements HabitRepository;

void main() {
  // The habit used by the edit-mode tests.
  final stored = Habit(
    id: 'h1',
    name: 'Read',
    iconKey: 'book',
    color: HabitColor.green,
    dailyTarget: 2,
    schedule: HabitSchedule(const {Weekday.monday, Weekday.friday}),
    createdAt: DateTime(2026, 11, 1, 9),
  );

  late MockHabitRepository repository;

  setUpAll(() async {
    await initializeTestLocales();
    registerFallbackValue(HabitColor.orange);
    registerFallbackValue(HabitSchedule.everyDay());
    registerFallbackValue(stored);
  });

  setUp(() => repository = MockHabitRepository());

  // `any()` calls have to run inside when() / verify(), hence the closure.
  Future<Either<Failure, Habit>> anyCreate() => repository.createHabit(
    name: any(named: 'name'),
    iconKey: any(named: 'iconKey'),
    color: any(named: 'color'),
    dailyTarget: any(named: 'dailyTarget'),
    schedule: any(named: 'schedule'),
  );

  void stubGet(Either<Failure, Habit> result) =>
      when(() => repository.getHabit('h1')).thenAnswer((_) async => result);

  /// Not pumpAndSettle: a focused text field and a spinner can keep asking
  /// for frames, so the tree may never "settle". A few fixed frames are
  /// enough for route, dialog and SnackBar transitions.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  /// Pushes the form on top of a stub home, so the page has somewhere to
  /// close to. The default view is tall so that the whole lazy list is built;
  /// the overflow tests pass the real phone size.
  Future<void> openForm(
    WidgetTester tester, {
    String? habitId,
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
    double textScale = 1,
    Size size = const Size(360, 2000),
  }) async {
    Widget form(BuildContext context, GoRouterState state) => BlocProvider(
      create: (_) => HabitFormCubit(
        repository,
        defaultIconKey: HabitIcons.keys.first,
        habitId: state.pathParameters['id'],
      ),
      child: const HabitFormPage(),
    );

    final router = GoRouter(
      routes: [
        GoRoute(
          path: AppRoutes.today,
          builder: (context, state) => const _HomeStub(),
        ),
        GoRoute(path: AppRoutes.newHabit, builder: form),
        GoRoute(path: AppRoutes.editHabitPattern, builder: form),
      ],
    );
    addTearDown(router.dispose);

    await pumpApp(
      tester,
      router: router,
      locale: locale,
      brightness: brightness,
      textScale: textScale,
      size: size,
    );
    unawaited(
      router.push<void>(
        habitId == null ? AppRoutes.newHabit : AppRoutes.editHabit(habitId),
      ),
    );
    await settle(tester);
  }

  TextField nameField(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField));

  group('adding', () {
    testWidgets('opens clean: title, no error and no delete button', (
      tester,
    ) async {
      await openForm(tester);

      expect(find.text('New habit'), findsOneWidget);
      expect(find.text('Give your habit a name'), findsNothing);
      expect(find.text('Delete habit'), findsNothing);
    });

    testWidgets('Save without a name shows the error and creates nothing', (
      tester,
    ) async {
      await openForm(tester);

      await tester.tap(find.byType(EvoloButton));
      await settle(tester);

      expect(find.text('Give your habit a name'), findsOneWidget);
      expect(find.byType(HabitFormPage), findsOneWidget);
      verifyNever(anyCreate);
    });

    testWidgets('Save creates with the trimmed name, then closes', (
      tester,
    ) async {
      when(anyCreate).thenAnswer((_) async => Right<Failure, Habit>(stored));
      await openForm(tester);

      await tester.enterText(find.byType(TextField), '  Drink water  ');
      await tester.pump();
      await tester.tap(find.byType(EvoloButton));
      await settle(tester);

      verify(
        () => repository.createHabit(
          name: 'Drink water',
          iconKey: HabitIcons.keys.first,
          color: HabitColor.orange,
          dailyTarget: 1,
          schedule: HabitSchedule.everyDay(),
        ),
      ).called(1);
      expect(find.byType(HabitFormPage), findsNothing);
      expect(find.byType(_HomeStub), findsOneWidget);
      expect(find.text('Habit added'), findsOneWidget);
    });

    testWidgets('shows the counter and the too-long error', (tester) async {
      await openForm(tester);

      await tester.enterText(find.byType(TextField), 'Hello');
      await settle(tester);

      expect(find.text('5/50'), findsOneWidget);
      expect(find.text('Up to 50 characters'), findsNothing);

      await tester.enterText(find.byType(TextField), 'a' * 51);
      await settle(tester);

      expect(find.text('51/50'), findsOneWidget);
      expect(find.text('Up to 50 characters'), findsOneWidget);
    });

    testWidgets('while saving: a spinner, no second save and no back', (
      tester,
    ) async {
      final completer = Completer<Either<Failure, Habit>>();
      when(anyCreate).thenAnswer((_) => completer.future);
      await openForm(tester);

      await tester.enterText(find.byType(TextField), 'Gym');
      await tester.pump();
      await tester.tap(find.byType(EvoloButton));
      await tester.pump();

      expect(
        find.descendant(
          of: find.byType(EvoloButton),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );

      await tester.tap(find.byType(EvoloButton));
      await tester.tap(find.byType(BackButton));
      await settle(tester);

      expect(find.byType(HabitFormPage), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      verify(anyCreate).called(1);

      completer.complete(Right<Failure, Habit>(stored));
      await settle(tester);

      expect(find.byType(HabitFormPage), findsNothing);
    });

    testWidgets('a failed save keeps the text and shows a SnackBar', (
      tester,
    ) async {
      when(
        anyCreate,
      ).thenAnswer((_) async => const Left<Failure, Habit>(DatabaseFailure()));
      await openForm(tester);

      await tester.enterText(find.byType(TextField), 'Gym');
      await tester.pump();
      await tester.tap(find.byType(EvoloButton));
      await settle(tester);

      expect(find.byType(HabitFormPage), findsOneWidget);
      expect(find.textContaining('save that change'), findsOneWidget);
      expect(nameField(tester).controller!.text, 'Gym');
    });

    testWidgets('the field direction follows the typed language', (
      tester,
    ) async {
      await openForm(tester);

      await tester.enterText(find.byType(TextField), 'قراءة');
      await tester.pump();
      expect(nameField(tester).textDirection, TextDirection.rtl);

      await tester.enterText(find.byType(TextField), 'Read');
      await tester.pump();
      expect(nameField(tester).textDirection, TextDirection.ltr);

      // No letters yet: the direction of the app applies.
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();
      expect(nameField(tester).textDirection, isNull);
    });
  });

  group('editing', () {
    testWidgets('fills the name and shows the delete button', (tester) async {
      stubGet(Right<Failure, Habit>(stored));

      await openForm(tester, habitId: 'h1');

      expect(find.text('Edit habit'), findsOneWidget);
      expect(nameField(tester).controller!.text, 'Read');
      expect(find.text('Delete habit'), findsOneWidget);
    });

    testWidgets('Save updates the habit, then closes', (tester) async {
      stubGet(Right<Failure, Habit>(stored));
      when(() => repository.updateHabit(any()))
          .thenAnswer((_) async => const Right<Failure, Unit>(unit));
      await openForm(tester, habitId: 'h1');

      await tester.enterText(find.byType(TextField), 'Read more');
      await tester.pump();
      await tester.tap(find.byType(EvoloButton));
      await settle(tester);

      verify(() => repository.updateHabit(stored.copyWith(name: 'Read more')))
          .called(1);
      expect(find.byType(HabitFormPage), findsNothing);
      expect(find.text('Changes saved'), findsOneWidget);
    });

    testWidgets('delete asks first, then deletes and confirms', (tester) async {
      stubGet(Right<Failure, Habit>(stored));
      when(() => repository.deleteHabit('h1'))
          .thenAnswer((_) async => const Right<Failure, Unit>(unit));
      await openForm(tester, habitId: 'h1');

      // The dialog names the stored habit, not the unsaved edit.
      await tester.enterText(find.byType(TextField), 'Something else');
      await tester.pump();
      await tester.tap(find.text('Delete habit'));
      await settle(tester);

      expect(find.text('Delete Read?'), findsOneWidget);
      verifyNever(() => repository.deleteHabit(any()));

      await tester.tap(find.text('Delete'));
      await settle(tester);

      verify(() => repository.deleteHabit('h1')).called(1);
      expect(find.byType(HabitFormPage), findsNothing);
      expect(find.text('Habit deleted'), findsOneWidget);
    });

    testWidgets('cancelling the delete dialog deletes nothing', (tester) async {
      stubGet(Right<Failure, Habit>(stored));
      await openForm(tester, habitId: 'h1');

      await tester.tap(find.text('Delete habit'));
      await settle(tester);
      await tester.tap(find.text('Cancel'));
      await settle(tester);

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(HabitFormPage), findsOneWidget);
      verifyNever(() => repository.deleteHabit(any()));
    });
  });

  group('leaving', () {
    testWidgets('back on an untouched form closes without asking', (
      tester,
    ) async {
      await openForm(tester);

      await tester.tap(find.byType(BackButton));
      await settle(tester);

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(HabitFormPage), findsNothing);
    });

    testWidgets('back with changes asks: keep editing or discard', (
      tester,
    ) async {
      await openForm(tester, locale: const Locale('ar'));
      await tester.enterText(find.byType(TextField), 'رياضة');
      await tester.pump();

      await tester.tap(find.byType(BackButton));
      await settle(tester);
      expect(find.text('تجاهل التغييرات؟'), findsOneWidget);

      await tester.tap(find.text('متابعة التعديل'));
      await settle(tester);
      expect(find.byType(HabitFormPage), findsOneWidget);
      expect(nameField(tester).controller!.text, 'رياضة');

      await tester.tap(find.byType(BackButton));
      await settle(tester);
      await tester.tap(find.text('تجاهل'));
      await settle(tester);

      expect(find.byType(HabitFormPage), findsNothing);
      verifyNever(anyCreate);
    });
  });

  group('loading problems', () {
    testWidgets('a missing habit says so and Go back closes', (tester) async {
      stubGet(const Left<Failure, Habit>(NotFoundFailure()));
      await openForm(tester, habitId: 'h1', locale: const Locale('ar'));

      expect(find.text('هذه العادة لم تعد موجودة'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);

      await tester.tap(find.text('رجوع'));
      await settle(tester);

      expect(find.byType(HabitFormPage), findsNothing);
    });

    testWidgets('a read error can be retried', (tester) async {
      stubGet(const Left<Failure, Habit>(DatabaseFailure()));
      await openForm(tester, habitId: 'h1');

      expect(find.text('Try again'), findsOneWidget);

      stubGet(Right<Failure, Habit>(stored));
      await tester.tap(find.text('Try again'));
      await settle(tester);

      expect(nameField(tester).controller!.text, 'Read');
    });
  });

  group('fits a 360 wide phone without overflow', () {
    const phone = Size(360, 800);
    const variants = [
      (Locale('en'), Brightness.light, 1.0),
      (Locale('ar'), Brightness.dark, 1.5),
    ];

    /// The list is lazy: only what is scrolled into view gets laid out, so
    /// the test has to walk all the way down.
    Future<void> scrollToEnd(WidgetTester tester) async {
      for (var i = 0; i < 10; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      await settle(tester);
    }

    for (final (locale, brightness, scale) in variants) {
      final label = '${locale.languageCode} ${brightness.name} x$scale';

      testWidgets('add mode with errors, $label', (tester) async {
        await openForm(
          tester,
          locale: locale,
          brightness: brightness,
          textScale: scale,
          size: phone,
        );
        expect(tester.takeException(), isNull);

        await tester.tap(find.byType(EvoloButton));
        await settle(tester);
        expect(tester.takeException(), isNull);

        await tester.enterText(find.byType(TextField), 'a' * 51);
        await settle(tester);
        expect(tester.takeException(), isNull);

        await scrollToEnd(tester);

        expect(find.byType(WeekdayPicker), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('edit mode with the schedule warning, $label', (
        tester,
      ) async {
        stubGet(
          Right<Failure, Habit>(
            stored.copyWith(name: 'اشرب كوب ماء كامل قبل كل وجبة طوال اليوم'),
          ),
        );
        await openForm(
          tester,
          habitId: 'h1',
          locale: locale,
          brightness: brightness,
          textScale: scale,
          size: phone,
        );
        expect(tester.takeException(), isNull);

        await scrollToEnd(tester);
        final sunday = find.byKey(const ValueKey('day-sunday'));
        await tester.ensureVisible(sunday);
        await tester.pump();
        await tester.tap(sunday);
        await settle(tester);
        await scrollToEnd(tester);

        expect(find.byIcon(Icons.info_outline), findsOneWidget);
        expect(find.byIcon(Icons.delete_outline), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  });
}

/// What is under the form: only here so the form has a page to close to.
class _HomeStub extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => const Scaffold();
}
