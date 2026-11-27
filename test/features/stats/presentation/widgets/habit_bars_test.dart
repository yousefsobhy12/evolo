import 'package:evolo/features/stats/presentation/widgets/habit_bars.dart';
import 'package:evolo/features/stats/presentation/widgets/pill_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../stats_test_host.dart';

const _fiveBars = [
  HabitBarData(name: 'Water', percent: 80),
  HabitBarData(name: 'Read', percent: 8),
  HabitBarData(name: 'Stretch', percent: null),
  HabitBarData(name: 'Walk', percent: 100),
  HabitBarData(name: 'Meditate', percent: 50),
];

Finder _scrollable() => find.descendant(
  of: find.byType(HabitBars),
  matching: find.byType(Scrollable),
);

void main() {
  testWidgets('one bar per habit, and the four tones repeat', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(statsHost(const HabitBars(bars: _fiveBars)));

    final tones = tester
        .widgetList<PillBar>(find.byType(PillBar))
        .map((bar) => bar.tone)
        .toList();
    expect(tones, [
      PillBarTone.brown,
      PillBarTone.rust,
      PillBarTone.olive,
      PillBarTone.pink,
      PillBarTone.brown,
    ]);
  });

  testWidgets('shows each name, and a dash when no day was counted', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(statsHost(const HabitBars(bars: _fiveBars)));

    for (final name in ['Water', 'Read', 'Stretch', 'Walk', 'Meditate']) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('a bar is read with its habit name and value', (tester) async {
    usePhoneSize(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(statsHost(const HabitBars(bars: _fiveBars)));

    expect(find.bySemanticsLabel('Water: 80%'), findsOneWidget);
    expect(find.bySemanticsLabel('Stretch: No counted days'), findsOneWidget);
    handle.dispose();
  });

  testWidgets('five bars scroll sideways on a 360 phone', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(statsHost(const HabitBars(bars: _fiveBars)));

    final position = tester.state<ScrollableState>(_scrollable()).position;
    expect(position.maxScrollExtent, greaterThan(0));
  });

  testWidgets('three bars fit without scrolling', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      statsHost(HabitBars(bars: _fiveBars.take(3).toList())),
    );

    final position = tester.state<ScrollableState>(_scrollable()).position;
    expect(position.maxScrollExtent, 0);
  });

  testWidgets('in Arabic the first bar is on the right', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      statsHost(const HabitBars(bars: _fiveBars), locale: const Locale('ar')),
    );

    final first = tester.getCenter(find.text('Water'));
    final second = tester.getCenter(find.text('Read'));
    expect(first.dx, greaterThan(second.dx));
  });

  testWidgets('a long name, Arabic, Dark and a large font do not overflow', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      statsHost(
        const HabitBars(
          bars: [
            HabitBarData(
              name: 'A very long habit name that keeps going and going',
              percent: 100,
            ),
          ],
        ),
        locale: const Locale('ar'),
        dark: true,
        textScaler: const TextScaler.linear(1.5),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
