import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The ARB files are edited by hand, so nothing stops one language from
/// missing a key or a placeholder. This catches it before a user does.
void main() {
  Map<String, dynamic> readArb(String file) =>
      jsonDecode(File('lib/core/l10n/arb/$file').readAsStringSync())
          as Map<String, dynamic>;

  Set<String> messageKeys(Map<String, dynamic> arb) =>
      arb.keys.where((key) => !key.startsWith('@')).toSet();

  final en = readArb('app_en.arb');
  final ar = readArb('app_ar.arb');

  test('Arabic has exactly the same messages as English', () {
    expect(messageKeys(ar), messageKeys(en));
  });

  test('every English message has a description for translators', () {
    for (final key in messageKeys(en)) {
      final meta = en['@$key'] as Map<String, dynamic>?;
      expect(meta?['description'], isA<String>(), reason: key);
    }
  });

  test('every placeholder appears in both languages', () {
    for (final key in messageKeys(en)) {
      final meta = en['@$key'] as Map<String, dynamic>?;
      final placeholders = meta?['placeholders'] as Map<String, dynamic>?;
      if (placeholders == null) continue;

      for (final name in placeholders.keys) {
        expect(en[key], contains('{$name'), reason: 'en $key {$name}');
        expect(ar[key], contains('{$name'), reason: 'ar $key {$name}');
      }
    }
  });

  test('no message is empty', () {
    for (final arb in [en, ar]) {
      for (final key in messageKeys(arb)) {
        expect((arb[key] as String).trim(), isNotEmpty, reason: key);
      }
    }
  });
}
