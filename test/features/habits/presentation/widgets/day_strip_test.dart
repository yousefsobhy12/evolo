import 'package:evolo/core/utils/calendar_day.dart';
import 'package:evolo/features/habits/domain/entities/habit_schedule.dart';
import 'package:evolo/features/habits/presentation/cubit/today_state.dart';
import 'package:evolo/features/habits/presentation/widgets/day_strip.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  // Sunday 2026-11-22 is today. With a Saturday week start the strip shows
  // Nov 21 (Sat) .. Nov 27 (Fri); Nov 23..27 are in the future.
  CalendarDay nov(int day) => CalendarDay(2026, 11, day);

  final days = TodayState(
    today: nov(22),
    selectedDay: nov(22),
    weekStart: Weekday.saturday,
    firstSelectableDay: nov(1),
  ).days;

  late List<CalendarDay> selected;
  late int previousTaps;
  late int nextTaps;

  setUpAll(initializeTestLocales);

  setUp(() {
    selected = [];
    previousTaps = 0;
    nextTaps = 0;
  });

  DayStrip strip({bool canGoPrevious = true, bool canGoNext = true}) {
    return DayStrip(
      days: days,
      title: 'November 2026',
      canGoPrevious: canGoPrevious,
      canGoNext: canGoNext,
      onSelectDay: selected.add,
      onPrevious: () => previousTaps++,
      onNext: () => nextTaps++,
    );
  }

  Future<void> pump(
    WidgetTester tester,
    Widget child, {
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) {
    return pumpApp(
      tester,
      home: Scaffold(body: child),
      locale: locale,
      brightness: brightness,
      textScale: textScale,
    );
  }

  testWidgets('shows the seven days of the week with their numbers', (
    tester,
  ) async {
    await pump(tester, strip());

    for (final number in ['21', '22', '23', '24', '25', '26', '27']) {
      expect(find.text(number), findsOneWidget);
    }
    expect(find.text('November 2026'), findsOneWidget);
  });

  testWidgets('tapping an open day reports it', (tester) async {
    await pump(tester, strip());

    await tester.tap(find.text('21'));

    expect(selected, [nov(21)]);
  });

  testWidgets('a future day cannot be opened', (tester) async {
    await pump(tester, strip());

    await tester.tap(find.text('25'));

    expect(selected, isEmpty);
  });

  testWidgets('the week buttons report taps when enabled', (tester) async {
    await pump(tester, strip());

    await tester.tap(find.byTooltip('Previous week'));
    await tester.tap(find.byTooltip('Next week'));

    expect(previousTaps, 1);
    expect(nextTaps, 1);
  });

  testWidgets('the week buttons do nothing when disabled', (tester) async {
    await pump(tester, strip(canGoPrevious: false, canGoNext: false));

    await tester.tap(find.byTooltip('Previous week'));
    await tester.tap(find.byTooltip('Next week'));

    expect(previousTaps, 0);
    expect(nextTaps, 0);
  });

  testWidgets('each day has a full-date label for screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, strip());

    expect(find.bySemanticsLabel('Sunday, November 22'), findsOneWidget);
    expect(find.bySemanticsLabel('Saturday, November 21'), findsOneWidget);

    handle.dispose();
  });

  group('fits a 360 wide phone without overflow', () {
    for (final locale in [const Locale('en'), const Locale('ar')]) {
      for (final brightness in Brightness.values) {
        for (final scale in [1.0, 1.5]) {
          testWidgets('${locale.languageCode} ${brightness.name} x$scale', (
            tester,
          ) async {
            await pump(
              tester,
              strip(),
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

  testWidgets('Arabic mirrors the strip: Saturday is on the right', (
    tester,
  ) async {
    await pump(tester, strip(), locale: const Locale('ar'));

    final saturday = tester.getCenter(find.text('21'));
    final friday = tester.getCenter(find.text('27'));

    expect(saturday.dx, greaterThan(friday.dx));
  });
}
