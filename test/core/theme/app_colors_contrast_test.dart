import 'package:evolo/core/theme/app_colors.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/contrast_ratio.dart';

/// Contrast of the token pairs the Today screen relies on.
///
/// Until S6 these numbers were hand calculations; now a test computes them.
/// Text needs 4.5:1, icons and other UI components need 3:1.
void main() {
  <String, AppColors>{
    'light': AppColors.light,
    'dark': AppColors.dark,
  }.forEach((name, c) {
    group(name, () {
      test('the FAB and "Set Now" (primaryDark) are readable and visible', () {
        expect(
          contrastRatio(c.onPrimaryDark, c.primaryDark),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(c.primaryDark, c.background),
          greaterThanOrEqualTo(3),
        );
      });

      test('card text is readable on the card surface', () {
        expect(
          contrastRatio(c.textPrimary, c.surface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(c.textSecondary, c.surface),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(c.textAccent, c.surface),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('the selected day (ink) is readable and visible', () {
        expect(contrastRatio(c.onInk, c.ink), greaterThanOrEqualTo(4.5));
        expect(contrastRatio(c.ink, c.background), greaterThanOrEqualTo(3));
      });

      test('the reminder card texts and its icon are readable', () {
        expect(
          contrastRatio(c.textPrimary, c.reminderCard),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrastRatio(c.textSecondary, c.reminderCard),
          greaterThanOrEqualTo(4.5),
        );
        // The bell sits on a surface-colored circle inside the card.
        expect(contrastRatio(c.textAccent, c.surface), greaterThanOrEqualTo(3));
        expect(
          contrastRatio(c.primaryDark, c.reminderCard),
          greaterThanOrEqualTo(3),
        );
      });

      test('accent text is readable on the screen background', () {
        expect(
          contrastRatio(c.textAccent, c.background),
          greaterThanOrEqualTo(4.5),
        );
      });

      test('the empty check circle is visible on the card surface', () {
        expect(contrastRatio(c.checkRing, c.surface), greaterThanOrEqualTo(3));
      });

      test('outlines are visible on the surface and the background', () {
        expect(contrastRatio(c.outline, c.surface), greaterThanOrEqualTo(3));
        expect(contrastRatio(c.outline, c.background), greaterThanOrEqualTo(3));
      });
    });
  });
}
