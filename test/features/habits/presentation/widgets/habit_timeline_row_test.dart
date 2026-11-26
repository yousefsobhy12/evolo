import 'package:evolo/features/habits/presentation/widgets/habit_card.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_check_button.dart';
import 'package:evolo/features/habits/presentation/widgets/habit_timeline_row.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/habit_fixtures.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  setUpAll(initializeTestLocales);

  Future<void> pump(
    WidgetTester tester, {
    bool isFirst = false,
    bool isLast = false,
    Locale locale = const Locale('en'),
  }) {
    return pumpApp(
      tester,
      locale: locale,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: HabitTimelineRow(
            item: todayItem(),
            isFirst: isFirst,
            isLast: isLast,
            onTap: () {},
            onDecrement: () {},
          ),
        ),
      ),
    );
  }

  double centerX(WidgetTester tester, Finder finder) =>
      tester.getCenter(finder).dx;

  group('the circle', () {
    testWidgets('is on the left of the card in English', (tester) async {
      await pump(tester);

      expect(
        centerX(tester, find.byType(HabitCheckButton)),
        lessThan(centerX(tester, find.byType(HabitCard))),
      );
    });

    testWidgets('is on the right of the card in Arabic', (tester) async {
      await pump(tester, locale: const Locale('ar'));

      expect(
        centerX(tester, find.byType(HabitCheckButton)),
        greaterThan(centerX(tester, find.byType(HabitCard))),
      );
    });

    testWidgets('is outside the card, with a 48 tap target', (tester) async {
      await pump(tester);

      final circle = tester.getRect(find.byType(HabitCheckButton));
      final card = tester.getRect(find.byType(HabitCard));
      expect(circle.overlaps(card), isFalse);
      expect(circle.size, const Size(48, 48));
    });

    testWidgets('is centered on the card, not on the gap under it', (
      tester,
    ) async {
      await pump(tester);

      expect(
        tester.getCenter(find.byType(HabitCheckButton)).dy,
        moreOrLessEquals(tester.getCenter(find.byType(HabitCard)).dy),
      );
    });
  });

  group('the timeline', () {
    final line = find.byKey(HabitTimelineRow.lineKey);

    testWidgets('runs through a middle row', (tester) async {
      await pump(tester);

      expect(line, paints..circle());
    });

    testWidgets('a single habit has no line', (tester) async {
      await pump(tester, isFirst: true, isLast: true);

      expect(line, paintsNothing);
    });

    testWidgets('follows the circle in both directions', (tester) async {
      for (final locale in [const Locale('en'), const Locale('ar')]) {
        await pump(tester, locale: locale);
        await tester.pumpAndSettle();

        expect(
          centerX(tester, line),
          moreOrLessEquals(centerX(tester, find.byType(HabitCheckButton))),
        );
      }
    });

    testWidgets('covers the gap so the next row continues it', (tester) async {
      await pump(tester);

      expect(
        tester.getRect(line).bottom,
        greaterThan(tester.getRect(find.byType(HabitCard)).bottom),
      );
    });
  });
}
