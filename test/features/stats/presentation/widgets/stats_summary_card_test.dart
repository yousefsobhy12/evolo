import 'package:evolo/features/stats/presentation/widgets/stats_summary_card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../stats_test_host.dart';

void main() {
  testWidgets('shows the three numbers with their labels', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      statsHost(
        const StatsSummaryCard(percent: 67, bestStreak: 30, totalCheckIns: 12),
      ),
    );

    expect(find.text('Completion rate'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('Best streak'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('Total check-ins'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('no counted day shows a dash that is read as words', (
    tester,
  ) async {
    usePhoneSize(tester);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      statsHost(
        const StatsSummaryCard(percent: null, bestStreak: 0, totalCheckIns: 0),
      ),
    );

    expect(find.text('—'), findsOneWidget);
    expect(find.text('0%'), findsNothing);
    expect(find.bySemanticsLabel(RegExp('No counted days')), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the streak unit follows the number', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      statsHost(
        const StatsSummaryCard(percent: 50, bestStreak: 1, totalCheckIns: 3),
      ),
    );
    expect(find.text('day (all time)'), findsOneWidget);

    await tester.pumpWidget(
      statsHost(
        const StatsSummaryCard(percent: 50, bestStreak: 30, totalCheckIns: 3),
      ),
    );
    expect(find.text('days (all time)'), findsOneWidget);
  });

  testWidgets('the three numbers sit side by side at the normal font', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      statsHost(
        const StatsSummaryCard(percent: 67, bestStreak: 30, totalCheckIns: 12),
      ),
    );

    final first = tester.getTopLeft(find.text('Completion rate'));
    final second = tester.getTopLeft(find.text('Best streak'));
    expect(second.dx, isNot(first.dx));
    expect(second.dy, first.dy);
  });

  testWidgets('the three numbers stack at a large font', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      statsHost(
        const StatsSummaryCard(percent: 67, bestStreak: 30, totalCheckIns: 12),
        textScaler: const TextScaler.linear(1.5),
      ),
    );

    final first = tester.getTopLeft(find.text('Completion rate'));
    final second = tester.getTopLeft(find.text('Best streak'));
    expect(second.dx, first.dx);
    expect(second.dy, greaterThan(first.dy));
  });

  testWidgets('Arabic, Dark, 360 and a large font do not overflow', (
    tester,
  ) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      statsHost(
        const StatsSummaryCard(
          percent: 100,
          bestStreak: 365,
          totalCheckIns: 1234,
        ),
        locale: const Locale('ar'),
        dark: true,
        textScaler: const TextScaler.linear(1.5),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
