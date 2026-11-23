import 'package:evolo/core/widgets/state_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  setUpAll(initializeTestLocales);

  testWidgets('shows the title, the message and the action', (tester) async {
    await pumpApp(
      tester,
      home: Scaffold(
        body: StateMessage(
          icon: Icons.error_outline,
          title: 'Title',
          message: 'Message',
          action: FilledButton(onPressed: () {}, child: const Text('Go')),
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.text('Message'), findsOneWidget);
    expect(find.text('Go'), findsOneWidget);
  });

  testWidgets('scrolls instead of overflowing in a very short space', (
    tester,
  ) async {
    await pumpApp(
      tester,
      size: const Size(360, 160),
      textScale: 1.5,
      home: const Scaffold(
        body: StateMessage(
          icon: Icons.error_outline,
          title: 'A fairly long title that wraps',
          message: 'A longer message that also wraps onto several lines.',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
