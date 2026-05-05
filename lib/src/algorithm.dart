// WCAG luminance uses [Color.computeLuminance]. APCA still reads 8-bit-style
// channels via [Color.red]/[Color.green]/[Color.blue].
// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:flutter/painting.dart';

/// The contrast algorithm to use when computing adaptive text color.
enum ContrastAlgorithm {
  /// WCAG 2.1 relative luminance formula (default).
  /// Guarantees ≥ 4.5:1 contrast ratio for AA compliance.
  wcag,

  /// Advanced Perceptual Contrast Algorithm (APCA) — the proposed WCAG 3.0
  /// standard. More perceptually accurate, especially for dark backgrounds.
  apca,
}

/// WCAG conformance level used as the minimum acceptable contrast ratio.
enum WcagLevel {
  /// AA — minimum contrast ratio of 4.5:1 for normal text.
  aa,

  /// AAA — enhanced contrast ratio of 7:1 for normal text.
  aaa,
}

// ---------------------------------------------------------------------------
// WCAG 2.1 luminance helpers
// ---------------------------------------------------------------------------

/// WCAG 2.1 relative luminance of [color] (**0.0**–**1.0**).
///
/// Delegates to [Color.computeLuminance] (same WCAG linearization and weights).
/// In debug mode, [Color.computeLuminance] asserts if [Color.colorSpace] is
/// [ColorSpace.extendedSRGB].
///
/// [isLight] / [isDark] use luminance **> 0.179** (WCAG crossover for black vs
/// white at 4.5:1), not [ThemeData.estimateBrightnessForColor], which follows
/// Material’s separate threshold for theme brightness.
double getLuminance(Color color) => color.computeLuminance();

/// WCAG 2.1 contrast ratio from two relative luminances in the range **0.0–1.0**.
///
/// Same result as [getContrastRatio] would yield for colors whose luminances
/// are [lumA] and [lumB], without recomputing linearization — useful when one
/// background luminance is shared across many candidates.
double wcagContrastRatioFromLuminance(double lumA, double lumB) {
  final lighter = max(lumA, lumB);
  final darker = min(lumA, lumB);
  return (lighter + 0.05) / (darker + 0.05);
}

/// Computes the WCAG 2.1 contrast ratio between [foreground] and [background].
///
/// Returns a value from **1.0** (identical colors) up to **21.0** (black vs white).
/// WCAG AA requires ≥ 4.5 for normal text.
double getContrastRatio(Color foreground, Color background) {
  return wcagContrastRatioFromLuminance(
    getLuminance(foreground),
    getLuminance(background),
  );
}

/// Returns `true` if [color] is perceptually light (luminance > 0.179).
///
/// The threshold **0.179** is the WCAG 2.1 luminance crossover so black and
/// white each reach at least **4.5:1** against the background. This is
/// intentionally not [ThemeData.estimateBrightnessForColor], which uses
/// Material’s brightness split for theming, not that WCAG guarantee.
bool isLight(Color color) => getLuminance(color) > 0.179;

/// Returns `true` if [color] is perceptually dark.
bool isDark(Color color) => !isLight(color);

// ---------------------------------------------------------------------------
// APCA helpers (Accessible Perceptual Contrast Algorithm)
// ---------------------------------------------------------------------------

/// Linearizes a channel for the APCA formula (exponent 2.4, no low-end ramp).
double _apcaLinearize(int channel) => pow(channel / 255.0, 2.4).toDouble();

/// Computes the APCA contrast value (Lc) between [text] and [background].
///
/// Returns a signed value; positive = dark text on light bg, negative = vice versa.
/// Typical readable minimum is |Lc| ≥ 60.
double getApcaContrast(Color text, Color background) {
  const double sRco = 0.2126729;
  const double sGco = 0.7151522;
  const double sBco = 0.0721750;
  const double normBg = 0.56;
  const double normTxt = 0.57;
  const double revTxt = 0.62;
  const double revBg = 0.65;
  const double scaleBoW = 1.14;
  const double scaleWoB = 1.14;
  const double loClip = 0.001;
  const double deltaYMin = 0.0005;
  const double loBoWOffset = 0.027;
  const double loWoBOffset = 0.027;

  final yBgRaw = sRco * _apcaLinearize(background.red) +
      sGco * _apcaLinearize(background.green) +
      sBco * _apcaLinearize(background.blue);

  final yTxtRaw = sRco * _apcaLinearize(text.red) +
      sGco * _apcaLinearize(text.green) +
      sBco * _apcaLinearize(text.blue);

  // Clamp tiny luminances so pure black / near-black text still yields a score
  // (without this, yTxt == 0 exits early and black-on-white incorrectly returns 0).
  final yBg = yBgRaw < loClip ? loClip : yBgRaw;
  final yTxt = yTxtRaw < loClip ? loClip : yTxtRaw;

  if ((yBg - yTxt).abs() < deltaYMin) return 0.0;

  double lc;
  if (yBg > yTxt) {
    // Dark text on light bg
    lc = (pow(yBg, normBg) - pow(yTxt, normTxt)) * scaleBoW;
    lc =
        lc < loBoWOffset ? lc - loBoWOffset * pow(lc / loBoWOffset, 1.414) : lc;
  } else {
    // Light text on dark bg
    lc = (pow(yBg, revBg) - pow(yTxt, revTxt)) * scaleWoB;
    lc = lc > -loWoBOffset
        ? lc + loWoBOffset * pow(-lc / loWoBOffset, 1.414)
        : lc;
  }

  return lc * 100.0;
}

// ---------------------------------------------------------------------------
// Core adaptive color picker
// ---------------------------------------------------------------------------

/// Returns the color from [palette] (or black/white if palette is null)
/// that provides the highest contrast against [background].
///
/// When [algorithm] is [ContrastAlgorithm.wcag] (default), contrast is
/// measured using the WCAG 2.1 contrast ratio formula.
/// When [algorithm] is [ContrastAlgorithm.apca], the APCA Lc value is used.
///
/// If two candidates produce equal contrast, the one that appears first in
/// [palette] is returned.
///
/// Example — simple black/white:
/// ```dart
/// final textColor = getAdaptiveColor(Colors.indigo[900]!);
/// // → Color(0xFFFFFFFF)  (white, luminance is low)
/// ```
///
/// Example — palette-aware:
/// ```dart
/// final textColor = getAdaptiveColor(
///   Colors.indigo[900]!,
///   palette: [Colors.orange, Colors.grey[200]!, Colors.yellow],
/// );
/// ```
Color getAdaptiveColor(
  Color background, {
  List<Color>? palette,
  ContrastAlgorithm algorithm = ContrastAlgorithm.wcag,
}) {
  final candidates = palette ?? const [Color(0xFF000000), Color(0xFFFFFFFF)];

  if (candidates.isEmpty) {
    // Fallback to black/white when an empty palette is passed.
    return isLight(background)
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
  }

  if (algorithm == ContrastAlgorithm.wcag) {
    final bgLum = getLuminance(background);
    var best = candidates.first;
    var bestScore = wcagContrastRatioFromLuminance(
      getLuminance(best),
      bgLum,
    );
    for (var i = 1; i < candidates.length; i++) {
      final c = candidates[i];
      final score = wcagContrastRatioFromLuminance(getLuminance(c), bgLum);
      if (score > bestScore) {
        bestScore = score;
        best = c;
      }
    }
    return best;
  }

  var bestApca = candidates.first;
  var bestApcaScore = getApcaContrast(bestApca, background).abs();
  for (var i = 1; i < candidates.length; i++) {
    final c = candidates[i];
    final score = getApcaContrast(c, background).abs();
    if (score > bestApcaScore) {
      bestApcaScore = score;
      bestApca = c;
    }
  }
  return bestApca;
}

/// Returns the minimum WCAG contrast ratio required for [level].
double wcagMinimumRatio(WcagLevel level) {
  switch (level) {
    case WcagLevel.aa:
      return 4.5;
    case WcagLevel.aaa:
      return 7.0;
  }
}

/// Returns `true` if the contrast between [foreground] and [background]
/// meets the [level] requirement (default: AA, 4.5:1).
bool meetsWcag(
  Color foreground,
  Color background, {
  WcagLevel level = WcagLevel.aa,
}) {
  return getContrastRatio(foreground, background) >= wcagMinimumRatio(level);
}
