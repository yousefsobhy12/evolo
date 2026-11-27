import 'package:evolo/features/stats/domain/entities/stats_period.dart';
import 'package:evolo/features/stats/presentation/widgets/stats_period_toggle.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../stats_test_host.dart';

void main() {
  testWidgets('shows both periods in English', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      statsHost(StatsPeriodToggle(period: StatsPeriod.week, onChanged: (_) {})),
    );

    expect(find.text('This week'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
  });

  testWidgets('shows both periods in Arabic', (tester) async {
    usePhoneSize(tester);
    await tester.pumpWidget(
      statsHost(
        StatsPeriodToggle(period: StatsPeriod.week, onChanged: (_) {}),
        locale: const Locale('ar'),
      ),
    );

    expect(find.text('هذا الأسبوع'), findsOneWidget);
    expect(find.text('هذا الشهر'), findsOneWidget);
  });

  testWidgets('tapping the other period reports it', (tester) async {
    usePhoneSize(tester);
    StatsPeriod? picked;
    await tester.pumpWidget(
      statsHost(
        StatsPeriodToggle(
          period: StatsPeriod.week,
          onChanged: (period) => picked = period,
        ),
      ),
    );

    await tester.tap(find.text('This month'));
    await tester.pump();

    expect(picked, StatsPeriod.month);
  });
}
