import 'package:evolo/core/theme/app_colors.dart';
import 'package:evolo/core/widgets/circle_icon_button.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/contrast_ratio.dart';
import '../../helpers/pump_app.dart';

void main() {
  Widget host(VoidCallback? onPressed, {double? size}) => Scaffold(
    body: Center(
      child: CircleIconButton(
        icon: Icons.close,
        tooltip: 'Close',
        onPressed: onPressed,
        size: size ?? CircleIconButton.defaultSize,
      ),
    ),
  );

  testWidgets('reports a tap', (tester) async {
    var taps = 0;
    await pumpApp(tester, home: host(() => taps++));

    await tester.tap(find.byTooltip('Close'));

    expect(taps, 1);
  });

  testWidgets('is disabled without a callback', (tester) async {
    await pumpApp(tester, home: host(null));

    final button = tester.widget<IconButton>(find.byType(IconButton));

    expect(button.onPressed, isNull);
  });

  testWidgets('is 56 by default and never below 48', (tester) async {
    await pumpApp(tester, home: host(() {}));

    expect(tester.getSize(find.byType(IconButton)), const Size.square(56));

    await pumpApp(tester, home: host(() {}, size: 48));
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.getSize(find.byType(IconButton)), const Size.square(48));
  });

  test('the icon is visible on the button in both themes', () {
    for (final colors in [AppColors.light, AppColors.dark]) {
      expect(
        contrastRatio(colors.textPrimary, colors.surface),
        greaterThanOrEqualTo(3),
      );
    }
  });
}
