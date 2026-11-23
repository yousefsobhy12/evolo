import 'dart:math' as math;
import 'dart:ui';

/// WCAG 2.x contrast ratio between two opaque colors (1:1 .. 21:1).
///
/// Thresholds used in this project: 4.5 for text, 3 for icons and other UI
/// components.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}
