import 'package:evolo/features/habits/domain/entities/habit_color.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/presentation/utils/habit_icons.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_color_picker.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_icon_picker.dart';
import 'package:evolo/features/habits/presentation/widgets/target_stepper.dart';
import 'package:evolo/features/habits/presentation/widgets/weekday_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/pump_app.dart';

Widget _page(Widget child) => Scaffold(
  body: SingleChildScrollView(
    padding: const EdgeInsetsDirectional.all(20),
    child: child,
  ),
);

void main() {
  setUpAll(initializeTestLocales);

  group('HabitIconPicker', () {
    Future<void> pump(
      WidgetTester tester, {
      String selected = 'water',
      ValueChanged<String>? onSelected,
      bool enabled = true,
      Locale locale = const Locale('en'),
      Brightness brightness = Brightness.light,
      double textScale = 1,
    }) {
      return pumpApp(
        tester,
        locale: locale,
        brightness: brightness,
        textScale: textScale,
        home: _page(
          HabitIconPicker(
            selectedKey: selected,
            color: HabitColor.green,
            onSelected: onSelected ?? (_) {},
            enabled: enabled,
          ),
        ),
      );
    }

    testWidgets('shows every icon and each is at least 48x48', (tester) async {
      await pump(tester);

      for (final key in HabitIcons.keys) {
        final finder = find.byKey(ValueKey('icon-$key'));
        expect(finder, findsOneWidget, reason: key);
        final size = tester.getSize(finder);
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('tapping an icon reports its key', (tester) async {
      String? picked;
      await pump(tester, onSelected: (key) => picked = key);

      await tester.tap(find.byKey(const ValueKey('icon-book')));
      expect(picked, 'book');
    });

    testWidgets('does nothing when disabled', (tester) async {
      String? picked;
      await pump(tester, enabled: false, onSelected: (key) => picked = key);

      await tester.tap(
        find.byKey(const ValueKey('icon-book')),
        warnIfMissed: false,
      );
      expect(picked, isNull);
    });

    testWidgets('has a localized screen-reader name', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester);
      expect(find.bySemanticsLabel('Water'), findsOneWidget);

      await pump(tester, locale: const Locale('ar'));
      expect(find.bySemanticsLabel('ماء'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('does not overflow in Arabic, Dark, big text', (tester) async {
      await pump(
        tester,
        locale: const Locale('ar'),
        brightness: Brightness.dark,
        textScale: 1.5,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('HabitColorPicker', () {
    Future<void> pump(
      WidgetTester tester, {
      HabitColor selected = HabitColor.orange,
      ValueChanged<HabitColor>? onSelected,
      bool enabled = true,
      Brightness brightness = Brightness.light,
    }) {
      return pumpApp(
        tester,
        brightness: brightness,
        home: _page(
          HabitColorPicker(
            selected: selected,
            onSelected: onSelected ?? (_) {},
            enabled: enabled,
          ),
        ),
      );
    }

    testWidgets('only the selected color shows a check', (tester) async {
      await pump(tester, selected: HabitColor.green);

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('color-green')),
          matching: find.byIcon(Icons.check),
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping a color reports it', (tester) async {
      HabitColor? picked;
      await pump(tester, onSelected: (c) => picked = c);

      await tester.tap(find.byKey(const ValueKey('color-pink')));
      expect(picked, HabitColor.pink);
    });

    testWidgets('does nothing when disabled (Dark)', (tester) async {
      HabitColor? picked;
      await pump(
        tester,
        enabled: false,
        brightness: Brightness.dark,
        onSelected: (c) => picked = c,
      );

      await tester.tap(
        find.byKey(const ValueKey('color-pink')),
        warnIfMissed: false,
      );
      expect(picked, isNull);
    });

    testWidgets('has localized screen-reader names', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester);
      expect(find.bySemanticsLabel('Orange'), findsOneWidget);
      expect(find.bySemanticsLabel('Green'), findsOneWidget);
      expect(find.bySemanticsLabel('Pink'), findsOneWidget);
      handle.dispose();
    });
  });

  group('WeekdayPicker', () {
    Future<void> pump(
      WidgetTester tester, {
      Set<Weekday>? selected,
      ValueChanged<Weekday>? onToggle,
      bool enabled = true,
      Locale locale = const Locale('en'),
      double textScale = 1,
    }) {
      return pumpApp(
        tester,
        locale: locale,
        textScale: textScale,
        home: _page(
          WeekdayPicker(
            selected: selected ?? Weekday.values.toSet(),
            onToggle: onToggle ?? (_) {},
            enabled: enabled,
          ),
        ),
      );
    }

    List<double> centersX(WidgetTester tester) => [
      for (final day in WeekdayPicker.displayOrder)
        tester.getCenter(find.byKey(ValueKey('day-${day.name}'))).dx,
    ];

    testWidgets('starts with Saturday: left to right in English', (
      tester,
    ) async {
      await pump(tester);

      expect(WeekdayPicker.displayOrder.first, Weekday.saturday);
      final xs = centersX(tester);
      expect(xs, equals(List.of(xs)..sort()));
    });

    testWidgets('starts with Saturday: right to left in Arabic', (
      tester,
    ) async {
      await pump(tester, locale: const Locale('ar'));

      final xs = centersX(tester);
      expect(xs, equals(List.of(xs)..sort((a, b) => b.compareTo(a))));
    });

    testWidgets('tapping a day reports it', (tester) async {
      Weekday? toggled;
      await pump(tester, onToggle: (d) => toggled = d);

      await tester.tap(find.byKey(const ValueKey('day-monday')));
      expect(toggled, Weekday.monday);
    });

    testWidgets('does nothing when disabled', (tester) async {
      Weekday? toggled;
      await pump(tester, enabled: false, onToggle: (d) => toggled = d);

      await tester.tap(
        find.byKey(const ValueKey('day-monday')),
        warnIfMissed: false,
      );
      expect(toggled, isNull);
    });

    testWidgets('each day has its full name for screen readers', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester);

      expect(find.bySemanticsLabel('Saturday'), findsOneWidget);
      expect(find.bySemanticsLabel('Friday'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('fits 360 wide with big text in Arabic', (tester) async {
      await pump(tester, locale: const Locale('ar'), textScale: 1.5);
      expect(tester.takeException(), isNull);
    });
  });

  group('TargetStepper', () {
    Future<void> pump(
      WidgetTester tester, {
      int value = 1,
      bool canDecrement = true,
      bool canIncrement = true,
      VoidCallback? onDecrement,
      VoidCallback? onIncrement,
      bool enabled = true,
      Locale locale = const Locale('en'),
    }) {
      return pumpApp(
        tester,
        locale: locale,
        home: _page(
          TargetStepper(
            value: value,
            canDecrement: canDecrement,
            canIncrement: canIncrement,
            onDecrement: onDecrement ?? () {},
            onIncrement: onIncrement ?? () {},
            enabled: enabled,
          ),
        ),
      );
    }

    testWidgets('describes the goal as a phrase', (tester) async {
      await pump(tester);
      expect(find.text('Once a day'), findsOneWidget);

      await pump(tester, value: 2);
      expect(find.text('Twice a day'), findsOneWidget);

      await pump(tester, value: 3);
      expect(find.text('3 times a day'), findsOneWidget);
    });

    testWidgets('the buttons report taps and are at least 48x48', (
      tester,
    ) async {
      var up = 0;
      var down = 0;
      await pump(tester, onIncrement: () => up++, onDecrement: () => down++);

      await tester.tap(find.byTooltip('Increase goal'));
      await tester.tap(find.byTooltip('Decrease goal'));
      expect(up, 1);
      expect(down, 1);

      for (final tooltip in ['Increase goal', 'Decrease goal']) {
        final size = tester.getSize(find.byTooltip(tooltip));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('a button is disabled at its limit', (tester) async {
      var down = 0;
      await pump(tester, canDecrement: false, onDecrement: () => down++);

      await tester.tap(find.byTooltip('Decrease goal'), warnIfMissed: false);
      expect(down, 0);

      await tester.tap(find.byTooltip('Increase goal'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('both buttons are disabled when the form is locked', (
      tester,
    ) async {
      await pump(tester, enabled: false);

      for (final button in tester.widgetList<IconButton>(
        find.byType(IconButton),
      )) {
        expect(button.onPressed, isNull);
      }
    });
  });
}
