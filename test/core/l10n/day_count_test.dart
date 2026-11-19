import 'package:evolo/core/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Arabic dayCount uses all plural forms', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('ar'));
    expect(l10n.dayCount(0), 'لا أيام');
    expect(l10n.dayCount(1), 'يوم واحد');
    expect(l10n.dayCount(2), 'يومان');
    expect(l10n.dayCount(3), '3 أيام');
    expect(l10n.dayCount(10), '10 أيام');
    expect(l10n.dayCount(11), '11 يومًا');
    expect(l10n.dayCount(99), '99 يومًا');
    expect(l10n.dayCount(100), '100 يوم');
  });

  test('English dayCount', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l10n.dayCount(0), 'No days');
    expect(l10n.dayCount(1), '1 day');
    expect(l10n.dayCount(2), '2 days');
  });
}
