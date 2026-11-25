import 'package:evolo/core/widgets/evolo_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  setUpAll(initializeTestLocales);

  Future<void> pumpButton(
    WidgetTester tester, {
    bool isLoading = false,
    VoidCallback? onPressed,
    IconData? icon,
    String? loadingLabel,
  }) {
    return pumpApp(
      tester,
      home: Scaffold(
        body: Center(
          child: EvoloButton(
            label: 'Save',
            onPressed: onPressed ?? () {},
            isLoading: isLoading,
            icon: icon,
            loadingLabel: loadingLabel,
          ),
        ),
      ),
    );
  }

  testWidgets('idle: shows the label, no spinner, and is pressable', (
    tester,
  ) async {
    var taps = 0;
    await pumpButton(tester, onPressed: () => taps++);

    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byType(EvoloButton));
    expect(taps, 1);
  });

  testWidgets('loading: shows a spinner, hides the label, ignores taps', (
    tester,
  ) async {
    var taps = 0;
    await pumpButton(tester, isLoading: true, onPressed: () => taps++);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final visibility = tester.widget<Visibility>(
      find.byWidgetPredicate((w) => w is Visibility && w.maintainSize),
    );
    expect(visibility.visible, isFalse);

    await tester.tap(find.byType(EvoloButton), warnIfMissed: false);
    expect(taps, 0);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
  });

  testWidgets('loading keeps the button size (no layout jump)', (tester) async {
    await pumpButton(tester);
    final idleSize = tester.getSize(find.byType(FilledButton));

    await pumpButton(tester, isLoading: true);
    expect(tester.getSize(find.byType(FilledButton)), idleSize);
  });

  testWidgets('loading keeps the primary colors, not the disabled grey', (
    tester,
  ) async {
    await pumpButton(tester, isLoading: true);

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.byType(Material),
      ),
    );
    expect(
      material.color,
      Theme.of(tester.element(find.byType(EvoloButton))).colorScheme.primary,
    );
  });

  testWidgets('the spinner is announced with the default and custom label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await pumpButton(tester, isLoading: true);
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);

    await pumpButton(tester, isLoading: true, loadingLabel: 'Saving');
    expect(find.bySemanticsLabel('Saving'), findsOneWidget);

    handle.dispose();
  });

  testWidgets('shows the icon when given', (tester) async {
    await pumpButton(tester, icon: Icons.check);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });
}
