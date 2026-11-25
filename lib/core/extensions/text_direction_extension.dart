import 'package:intl/intl.dart' as intl;
import 'package:material_ui/material_ui.dart';

final _firstLetter = RegExp(r'\p{L}', unicode: true);

/// Text direction by the language of the text itself (first letter), for
/// user-typed content such as a habit name.
extension StringTextDirection on String {
  /// [TextDirection.rtl] or [TextDirection.ltr], or null when the text has no
  /// letters yet (empty, digits, punctuation, emoji): the caller then keeps
  /// the direction of the app.
  TextDirection? get detectedTextDirection {
    // Only the first letter is checked: `Bidi` treats emoji (surrogate
    // pairs) as left-to-right, so a name starting with one would be
    // misjudged if the whole text were passed.
    final letter = _firstLetter.stringMatch(this);
    if (letter == null) return null;
    if (intl.Bidi.startsWithRtl(letter)) return TextDirection.rtl;
    if (intl.Bidi.startsWithLtr(letter)) return TextDirection.ltr;
    return null;
  }

  /// [detectedTextDirection], or [fallback] when the text is neutral.
  TextDirection textDirectionOr(TextDirection fallback) =>
      detectedTextDirection ?? fallback;
}
