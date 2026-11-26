import 'package:evolo/core/widgets/circle_icon_button.dart';
import 'package:evolo/core/widgets/page_header.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  const title = 'Your progress and insights';

  Widget host({Widget? trailing}) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [PageHeader(title: title, trailing: trailing)],
      ),
    ),
  );

  Widget close() =>
      CircleIconButton(icon: Icons.close, tooltip: 'Close', onPressed: () {});

  testWidgets('shows the title without a trailing widget', (tester) async {
    await pumpApp(tester, home: host());

    expect(find.text(title), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('the trailing widget is on the right in English', (tester) async {
    await pumpApp(tester, home: host(trailing: close()));

    expect(
      tester.getCenter(find.byType(IconButton)).dx,
      greaterThan(tester.getCenter(find.text(title)).dx),
    );
  });

  testWidgets('the trailing widget is on the left in Arabic', (tester) async {
    await pumpApp(
      tester,
      home: host(trailing: close()),
      locale: const Locale('ar'),
    );

    expect(
      tester.getCenter(find.byType(IconButton)).dx,
      lessThan(tester.getCenter(find.text(title)).dx),
    );
  });

  testWidgets('does not overflow at 360 with a 1.5 font', (tester) async {
    await pumpApp(
      tester,
      home: host(trailing: close()),
      textScale: 1.5,
      brightness: Brightness.dark,
    );

    expect(tester.takeException(), isNull);
  });
}
