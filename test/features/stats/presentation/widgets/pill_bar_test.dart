import 'package:evolo/core/theme/app_colors.dart';
import 'package:evolo/core/theme/app_theme.dart';
import 'package:evolo/features/stats/presentation/widgets/pill_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _width = 82.0;
const _height = 200.0;

Widget _host(
  Widget child, {
  required ThemeData theme,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    theme: theme,
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: textScaler),
      child: app!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

PillBar _bar({
  required int? percent,
  required String label,
  PillBarTone tone = PillBarTone.olive,
}) {
  return PillBar(
    percent: percent,
    label: label,
    semanticsLabel: 'Water, $label',
    tone: tone,
  );
}

Color? _numberColor(WidgetTester tester, String label) =>
    tester.widget<Text>(find.text(label)).style?.color;

void main() {
  group('PillBarTone', () {
    test('the colors repeat after four bars', () {
      expect(PillBarTone.forIndex(0), PillBarTone.brown);
      expect(PillBarTone.forIndex(3), PillBarTone.pink);
      expect(PillBarTone.forIndex(4), PillBarTone.brown);
      expect(PillBarTone.forIndex(5), PillBarTone.rust);
    });

    test('each tone maps to its own fill and number color', () {
      const c = AppColors.light;
      expect(PillBarTone.brown.fill(c), c.barBrown);
      expect(PillBarTone.rust.fill(c), c.barRust);
      expect(PillBarTone.olive.fill(c), c.barOlive);
      expect(PillBarTone.pink.fill(c), c.barPink);
      expect(PillBarTone.brown.onFill(c), c.onBarBrown);
      expect(PillBarTone.rust.onFill(c), c.onBarRust);
      expect(PillBarTone.olive.onFill(c), c.onBarOlive);
      expect(PillBarTone.pink.onFill(c), c.onBarPink);
    });
  });

  <String, (ThemeData, AppColors)>{
    'light': (AppTheme.light(const Locale('en')), AppColors.light),
    'dark': (AppTheme.dark(const Locale('en')), AppColors.dark),
  }.forEach((name, setup) {
    final (theme, colors) = setup;

    group('PillBar ($name)', () {
      testWidgets('a tall fill carries the number inside it', (tester) async {
        await tester.pumpWidget(
          _host(_bar(percent: 80, label: '80%'), theme: theme),
        );

        expect(_numberColor(tester, '80%'), colors.onBarOlive);

        // The fill covers the bottom 80%, so the top of the fill is 20% down.
        final bar = tester.getRect(find.byType(PillBar));
        final number = tester.getRect(find.text('80%'));
        expect(number.top, greaterThan(bar.top + _height * 0.2));
        expect(number.bottom, lessThan(bar.bottom));
      });

      testWidgets('a short fill puts the number above it, on the track', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(_bar(percent: 8, label: '8%'), theme: theme),
        );

        expect(_numberColor(tester, '8%'), colors.textPrimary);

        // The fill is the bottom 8%: the number must end above its top edge.
        final bar = tester.getRect(find.byType(PillBar));
        final number = tester.getRect(find.text('8%'));
        expect(number.bottom, lessThanOrEqualTo(bar.bottom - _height * 0.08));
      });

      testWidgets('0% shows the number on the track', (tester) async {
        await tester.pumpWidget(
          _host(_bar(percent: 0, label: '0%'), theme: theme),
        );

        expect(_numberColor(tester, '0%'), colors.textPrimary);
      });

      testWidgets('no data (null) shows the dash on the track', (tester) async {
        await tester.pumpWidget(
          _host(_bar(percent: null, label: '—'), theme: theme),
        );

        expect(_numberColor(tester, '—'), colors.textPrimary);
      });

      testWidgets('100% fits the number inside, with no overflow', (
        tester,
      ) async {
        await tester.pumpWidget(
          _host(_bar(percent: 100, label: '100%'), theme: theme),
        );

        expect(tester.takeException(), isNull);
        expect(_numberColor(tester, '100%'), colors.onBarOlive);
      });

      testWidgets('a larger system font moves the number out of the fill', (
        tester,
      ) async {
        // 25% of 200 = 50. One line (17 x 1.3) plus 12 padding on both sides
        // is about 46, so the number fits inside at normal size. At 1.5x the
        // line is taller and it no longer fits, so it moves above the fill.
        await tester.pumpWidget(
          _host(_bar(percent: 25, label: '25%'), theme: theme),
        );
        expect(_numberColor(tester, '25%'), colors.onBarOlive);

        await tester.pumpWidget(
          _host(
            _bar(percent: 25, label: '25%'),
            theme: theme,
            textScaler: const TextScaler.linear(1.5),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(_numberColor(tester, '25%'), colors.textPrimary);
      });

      testWidgets('the bar is one semantics node with the given label', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          _host(_bar(percent: 80, label: '80%'), theme: theme),
        );

        expect(find.bySemanticsLabel('Water, 80%'), findsOneWidget);
        handle.dispose();
      });

      testWidgets('the bar has the size it was given', (tester) async {
        await tester.pumpWidget(
          _host(_bar(percent: 50, label: '50%'), theme: theme),
        );

        expect(
          tester.getSize(find.byType(PillBar)),
          const Size(_width, _height),
        );
      });
    });
  });
}
