import 'package:evolo/features/habits/domain/entities/today_item.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_card.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_check_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/habit_fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late int taps;
  late int decrements;

  setUpAll(initializeTestLocales);

  setUp(() {
    taps = 0;
    decrements = 0;
  });

  Future<void> pump(
    WidgetTester tester,
    TodayItem item, {
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) {
    return pumpApp(
      tester,
      home: Scaffold(
        // Align loosens the tight body constraints, so the card takes its
        // own height like it does inside the real list.
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: HabitCard(
              item: item,
              onTap: () => taps++,
              onDecrement: () => decrements++,
            ),
          ),
        ),
      ),
      locale: locale,
      brightness: brightness,
      textScale: textScale,
    );
  }

  group('a habit with a goal of 1', () {
    testWidgets('shows its name and an invitation to start a streak', (
      tester,
    ) async {
      await pump(tester, todayItem(name: 'Read'));

      expect(find.text('Read'), findsOneWidget);
      expect(find.text('Start your streak today'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsNothing);
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('a tap on the circle reports it', (tester) async {
      await pump(tester, todayItem());

      await tester.tap(find.byType(HabitCheckButton));

      expect(taps, 1);
    });

    testWidgets('a done habit shows a check and a tap still reports', (
      tester,
    ) async {
      await pump(tester, todayItem(count: 1));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.byType(HabitCheckButton));
      expect(taps, 1);
    });

    testWidgets('the circle is labeled with the habit name', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, todayItem(name: 'Read'));

      expect(find.bySemanticsLabel('Complete Read'), findsOneWidget);

      await pump(tester, todayItem(name: 'Read', count: 1));
      expect(find.bySemanticsLabel('Undo Read'), findsOneWidget);

      handle.dispose();
    });
  });

  group('a habit with a goal above 1', () {
    testWidgets('shows the progress and a plus in the circle', (tester) async {
      await pump(tester, todayItem(count: 3, target: 8));

      expect(find.text('3 / 8'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('the circle adds one and the minus removes one', (
      tester,
    ) async {
      await pump(tester, todayItem(count: 3, target: 8));

      await tester.tap(find.byType(HabitCheckButton));
      await tester.tap(find.byIcon(Icons.remove));

      expect(taps, 1);
      expect(decrements, 1);
    });

    testWidgets('the minus is disabled at zero', (tester) async {
      await pump(tester, todayItem(target: 8));

      final minus = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.remove),
      );
      expect(minus.onPressed, isNull);

      await tester.tap(find.byIcon(Icons.remove));
      expect(decrements, 0);
    });

    testWidgets('a finished counter shows a check and ignores the circle', (
      tester,
    ) async {
      await pump(tester, todayItem(count: 8, target: 8));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);

      await tester.tap(find.byType(HabitCheckButton));
      expect(taps, 0);

      // The minus still works to take a count back.
      await tester.tap(find.byIcon(Icons.remove));
      expect(decrements, 1);
    });
  });

  group('streak line', () {
    testWidgets('shows the current streak', (tester) async {
      await pump(tester, todayItem(streak: 5));

      expect(find.text('Streak: 5 days'), findsOneWidget);
    });

    testWidgets('warns when the streak is at risk', (tester) async {
      await pump(tester, todayItem(streak: 5, atRisk: true));

      expect(find.text('At risk'), findsOneWidget);
    });

    testWidgets('does not warn when there is no streak to lose', (
      tester,
    ) async {
      await pump(tester, todayItem(atRisk: true));

      expect(find.text('At risk'), findsNothing);
    });

    testWidgets('shows the freezes in stock', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, todayItem(streak: 7, freezes: 2));

      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      expect(
        find.bySemanticsLabel('2 streak freezes available'),
        findsOneWidget,
      );

      handle.dispose();
    });

    testWidgets('shows no freeze badge when there are none', (tester) async {
      await pump(tester, todayItem(streak: 7));

      expect(find.byIcon(Icons.ac_unit), findsNothing);
    });
  });

  group('the busiest card fits a 360 wide phone without overflow', () {
    // Counter + long name + streak + at-risk + freezes: the worst case.
    final worst = todayItem(
      name: 'Drink a full glass of water before every single meal',
      count: 3,
      target: 8,
      streak: 12,
      freezes: 2,
      atRisk: true,
    );

    for (final locale in [const Locale('en'), const Locale('ar')]) {
      for (final brightness in Brightness.values) {
        for (final scale in [1.0, 1.5]) {
          testWidgets('${locale.languageCode} ${brightness.name} x$scale', (
            tester,
          ) async {
            await pump(
              tester,
              worst,
              locale: locale,
              brightness: brightness,
              textScale: scale,
            );

            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
