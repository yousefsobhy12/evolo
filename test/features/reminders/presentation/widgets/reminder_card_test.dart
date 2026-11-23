import 'package:evolo/features/reminders/presentation/widgets/reminder_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  late int taps;

  setUpAll(initializeTestLocales);
  setUp(() => taps = 0);

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
    double textScale = 1,
  }) {
    return pumpApp(
      tester,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ReminderCard(
              title: 'Never miss a habit',
              message: "Pick a time and we'll remind you gently.",
              actionLabel: 'Set now',
              onAction: () => taps++,
            ),
          ),
        ),
      ),
      locale: locale,
      brightness: brightness,
      textScale: textScale,
    );
  }

  testWidgets('shows the texts and reports the button tap', (tester) async {
    await pump(tester);

    expect(find.text('Never miss a habit'), findsOneWidget);
    expect(find.textContaining('remind you gently'), findsOneWidget);

    await tester.tap(find.text('Set now'));

    expect(taps, 1);
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
