import 'package:evolo/app.dart';
import 'package:evolo/core/di/injection.dart';
import 'package:evolo/core/router/route_error_page.dart';
import 'package:evolo/dev/home_page.dart';
import 'package:evolo/dev/theme_showcase_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    await configureDependencies();
  });

  tearDown(getIt.reset);

  Future<void> pumpApp(WidgetTester tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('ar');
    addTearDown(tester.platformDispatcher.clearLocaleTestValue);
    await tester.pumpWidget(const EvoloApp());
    await tester.pumpAndSettle();
  }

  TextDirection direction(WidgetTester tester) =>
      Directionality.of(tester.element(find.byType(Scaffold)));

  testWidgets('starts on Home in Arabic (RTL)', (tester) async {
    await pumpApp(tester);

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(direction(tester), TextDirection.rtl);
  });

  testWidgets('language toggle flips direction and text', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.translate));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(direction(tester), TextDirection.ltr);
  });

  testWidgets('opens Theme Showcase and comes back', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('فتح معرض الثيم'));
    await tester.pumpAndSettle();
    expect(find.byType(ThemeShowcasePage), findsOneWidget);

    getIt<GoRouter>().pop();
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('unknown route shows localized error page', (tester) async {
    await pumpApp(tester);

    getIt<GoRouter>().go('/nope');
    await tester.pumpAndSettle();
    expect(find.byType(RouteErrorPage), findsOneWidget);
    expect(find.text('الصفحة غير موجودة'), findsOneWidget);

    await tester.tap(find.text('العودة للرئيسية'));
    await tester.pumpAndSettle();
    expect(find.byType(HomePage), findsOneWidget);
  });
}
