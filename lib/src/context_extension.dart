import 'package:flutter/widgets.dart';

import 'adaptive_text_theme.dart';
import 'algorithm.dart';

/// Ergonomic helpers when building UI without [AdaptiveText].
///
/// Uses the same resolution rules: optional overrides merge with the nearest
/// [AdaptiveTextTheme], then fall back to WCAG black/white.
extension AdaptiveTextBuildContext on BuildContext {
  /// Nearest [AdaptiveTextThemeData], or `null` if there is no ancestor theme.
  AdaptiveTextThemeData? get adaptiveTextTheme =>
      AdaptiveTextTheme.maybeOf(this);

  /// Resolves a foreground [Color] the same way [AdaptiveText] does.
  ///
  /// [backgroundColor], [palette], and [algorithm] override inherited theme
  /// values when non-null. Requires either [backgroundColor] or an
  /// [AdaptiveTextTheme] ancestor that supplies `backgroundColor`.
  Color adaptiveForegroundColor({
    Color? backgroundColor,
    List<Color>? palette,
    ContrastAlgorithm? algorithm,
  }) {
    final inherited = AdaptiveTextTheme.maybeOf(this);
    final bg = backgroundColor ?? inherited?.backgroundColor;
    assert(
      bg != null,
      'adaptiveForegroundColor requires [backgroundColor] or an '
      '[AdaptiveTextTheme] ancestor with a backgroundColor.',
    );
    final pal = palette ?? inherited?.palette;
    final algo = algorithm ?? inherited?.algorithm ?? ContrastAlgorithm.wcag;
    return getAdaptiveColor(
      bg!,
      palette: pal,
      algorithm: algo,
    );
  }
}
