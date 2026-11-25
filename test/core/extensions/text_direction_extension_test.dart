import 'package:evolo/core/extensions/text_direction_extension.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('detectedTextDirection', () {
    test('Arabic text is rtl', () {
      expect('قراءة كتاب'.detectedTextDirection, TextDirection.rtl);
    });

    test('English text is ltr', () {
      expect('Read a book'.detectedTextDirection, TextDirection.ltr);
    });

    test('leading digits and emoji do not decide the direction', () {
      expect('10 صفحات'.detectedTextDirection, TextDirection.rtl);
      expect('😀 قراءة'.detectedTextDirection, TextDirection.rtl);
      expect('10 pages'.detectedTextDirection, TextDirection.ltr);
    });

    test('text without letters has no direction', () {
      expect(''.detectedTextDirection, isNull);
      expect('123 !?'.detectedTextDirection, isNull);
    });
  });

  group('textDirectionOr', () {
    test('uses the fallback only for neutral text', () {
      expect(''.textDirectionOr(TextDirection.rtl), TextDirection.rtl);
      expect('abc'.textDirectionOr(TextDirection.rtl), TextDirection.ltr);
      expect('ع'.textDirectionOr(TextDirection.ltr), TextDirection.rtl);
      expect('😀 Read'.detectedTextDirection, TextDirection.ltr);
    });
  });
}
