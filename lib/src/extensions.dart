import 'package:flutter/painting.dart';
import 'algorithm.dart';

/// Convenience extensions on Flutter's [Color] class.
///
/// These let you resolve adaptive text colors directly from any [Color]
/// instance without importing the algorithm module explicitly.
///
/// ```dart
/// final bg = Colors.indigo[900]!;
/// Text('Hello', style: TextStyle(color: bg.adaptiveTextColor));
/// ```
extension AdaptiveColorExtension on Color {
  // -------------------------------------------------------------------------
  // Adaptive text color
  // -------------------------------------------------------------------------

  /// Returns either black or white — whichever has a higher WCAG 2.1 contrast
  /// ratio against this color.
  ///
  /// The returned color always meets WCAG AA (≥ 4.5:1).
  ///
  /// ```dart
  /// Colors.deepPurple.adaptiveTextColor  // → white
  /// Colors.yellow.adaptiveTextColor      // → black
  /// ```
  Color get adaptiveTextColor => getAdaptiveColor(this);

  /// Returns the color from [palette] that provides the highest WCAG 2.1
  /// contrast ratio against this color.
  ///
  /// Falls back to black/white if [palette] is empty.
  ///
  /// ```dart
  /// Colors.indigo[900]!.adaptiveTextColorFrom(
  ///   [Colors.orange, Colors.grey[200]!, Colors.yellow],
  /// );
  /// ```
  Color adaptiveTextColorFrom(
    List<Color> palette, {
    ContrastAlgorithm algorithm = ContrastAlgorithm.wcag,
  }) =>
      getAdaptiveColor(this, palette: palette, algorithm: algorithm);

  // -------------------------------------------------------------------------
  // Brightness helpers
  // -------------------------------------------------------------------------

  /// Returns `true` if this color is perceptually light.
  ///
  /// Uses the WCAG 2.1 relative luminance formula with a threshold of 0.179,
  /// which guarantees that both black and white achieve ≥ 4.5:1 contrast.
  ///
  /// ```dart
  /// Colors.white.isLight  // true
  /// Colors.black.isLight  // false
  /// ```
  bool get isLight => getLuminance(this) > 0.179;

  /// Returns `true` if this color is perceptually dark.
  bool get isDark => !isLight;

  // -------------------------------------------------------------------------
  // Luminance & contrast
  // -------------------------------------------------------------------------

  /// Returns the WCAG 2.1 relative luminance of this color (0 – 1).
  ///
  /// 0 = absolute black, 1 = absolute white.
  double get relativeLuminance => getLuminance(this);

  /// Returns the WCAG 2.1 contrast ratio between this color and [other].
  ///
  /// Range: **1.0**–**21.0**. A ratio ≥ 4.5 meets WCAG AA.
  ///
  /// ```dart
  /// Colors.black.contrastRatioWith(Colors.white)  // → 21.0
  /// ```
  double contrastRatioWith(Color other) => getContrastRatio(this, other);

  /// Returns `true` if the contrast between this color and [other] meets the
  /// specified [level] (default: [WcagLevel.aa], 4.5:1).
  bool meetsWcagWith(Color other, {WcagLevel level = WcagLevel.aa}) =>
      meetsWcag(this, other, level: level);

  // -------------------------------------------------------------------------
  // APCA contrast
  // -------------------------------------------------------------------------

  /// Returns the APCA Lc contrast value between this color (as text) and
  /// [background].
  ///
  /// Positive = dark text on light bg. Negative = light text on dark bg.
  /// A magnitude of ≥ 60 is generally considered readable.
  double apcaContrastOn(Color background) => getApcaContrast(this, background);
}
