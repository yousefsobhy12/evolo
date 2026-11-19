import 'package:evolo/core/utils/breakpoints.dart';
import 'package:evolo/core/widgets/max_content_width.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WindowSize.fromWidth', () {
    test('compact below 600', () {
      expect(WindowSize.fromWidth(360), WindowSize.compact);
      expect(WindowSize.fromWidth(599.9), WindowSize.compact);
    });

    test('medium from 600 to 839', () {
      expect(WindowSize.fromWidth(600), WindowSize.medium);
      expect(WindowSize.fromWidth(839.9), WindowSize.medium);
    });

    test('expanded from 840', () {
      expect(WindowSize.fromWidth(840), WindowSize.expanded);
      expect(WindowSize.fromWidth(1280), WindowSize.expanded);
    });
  });

  group('MaxContentWidth', () {
    const key = Key('content');

    Future<void> pump(WidgetTester tester, double width) async {
      tester.view
        ..physicalSize = Size(width, 800)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.rtl,
          child: MaxContentWidth(child: SizedBox.expand(key: key)),
        ),
      );
    }

    testWidgets('caps and centers on a wide screen', (tester) async {
      await pump(tester, 1200);

      expect(tester.getSize(find.byKey(key)).width, 600);
      expect(tester.getTopLeft(find.byKey(key)).dx, 300);
    });

    testWidgets('does not shrink on a phone', (tester) async {
      await pump(tester, 400);

      expect(tester.getSize(find.byKey(key)).width, 400);
    });
  });

  testWidgets('context.windowSize follows the screen width', (tester) async {
    tester.view
      ..physicalSize = const Size(700, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late WindowSize size;
    await tester.pumpWidget(
      MediaQuery.fromView(
        view: tester.view,
        child: Builder(
          builder: (context) {
            size = context.windowSize;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(size, WindowSize.medium);
  });
}
