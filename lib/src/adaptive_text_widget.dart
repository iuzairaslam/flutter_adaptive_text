import 'package:flutter/widgets.dart';
import 'algorithm.dart';
import 'adaptive_text_theme.dart';

/// A drop-in replacement for Flutter's [Text] widget that automatically
/// chooses a legible text color based on the provided (or inherited)
/// background color.
///
/// ### Basic usage — explicit background color
/// ```dart
/// AdaptiveText(
///   'Hello World',
///   backgroundColor: Colors.indigo[900]!,
/// )
/// ```
///
/// ### Palette-aware — pick the best color from your design system
/// ```dart
/// AdaptiveText(
///   'Hello World',
///   backgroundColor: Colors.indigo[900]!,
///   palette: [Colors.orange, Colors.grey[200]!, Colors.yellow[700]!],
/// )
/// ```
///
/// ### Context-aware — reads background from [AdaptiveTextTheme]
/// Wrap your subtree with [AdaptiveTextTheme] and omit [backgroundColor]:
/// ```dart
/// AdaptiveTextTheme(
///   backgroundColor: Colors.indigo[900]!,
///   child: AdaptiveText('Hello World'),
/// )
/// ```
///
/// All standard [Text] parameters are forwarded to the underlying [Text]
/// widget. If you supply a [style] with an explicit [TextStyle.color], that
/// color takes precedence over the adaptive resolution.
class AdaptiveText extends StatelessWidget {
  /// Creates an [AdaptiveText] widget.
  ///
  /// Either [backgroundColor] must be provided, or an [AdaptiveTextTheme]
  /// ancestor must be present in the widget tree.
  const AdaptiveText(
    this.data, {
    super.key,
    this.backgroundColor,
    this.palette,
    this.algorithm,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  /// The text content to display.
  final String data;

  /// The background color against which text legibility is evaluated.
  ///
  /// If `null`, [AdaptiveTextTheme.maybeOf] is used to resolve it from context.
  /// An [AssertionError] is thrown in debug mode if neither is provided.
  final Color? backgroundColor;

  /// An optional palette of candidate text colors.
  ///
  /// When provided, the color with the highest contrast ratio against
  /// [backgroundColor] is chosen. When `null`, falls back to black or white.
  final List<Color>? palette;

  /// The contrast algorithm used to evaluate candidate colors.
  ///
  /// When `null`, inherits [AdaptiveTextThemeData.algorithm] from an
  /// [AdaptiveTextTheme] ancestor; otherwise defaults to [ContrastAlgorithm.wcag].
  /// Use [ContrastAlgorithm.apca] for the perceptual APCA formula (WCAG 3.0 proposal).
  final ContrastAlgorithm? algorithm;

  // ---- Standard Text parameters (forwarded as-is) -------------------------

  /// See [Text.style]. An explicit [TextStyle.color] overrides the adaptive color.
  final TextStyle? style;

  /// See [Text.strutStyle].
  final StrutStyle? strutStyle;

  /// See [Text.textAlign].
  final TextAlign? textAlign;

  /// See [Text.textDirection].
  final TextDirection? textDirection;

  /// See [Text.locale].
  final Locale? locale;

  /// See [Text.softWrap].
  final bool? softWrap;

  /// See [Text.overflow].
  final TextOverflow? overflow;

  /// See [Text.textScaler].
  final TextScaler? textScaler;

  /// See [Text.maxLines].
  final int? maxLines;

  /// See [Text.semanticsLabel].
  final String? semanticsLabel;

  /// See [Text.textWidthBasis].
  final TextWidthBasis? textWidthBasis;

  /// See [Text.textHeightBehavior].
  final TextHeightBehavior? textHeightBehavior;

  /// See [Text.selectionColor].
  final Color? selectionColor;

  /// Resolves adaptive color from [backgroundColor] / theme, then builds [Text].
  @override
  Widget build(BuildContext context) {
    final inherited = AdaptiveTextTheme.maybeOf(context);

    final Color? resolvedBg = backgroundColor ?? inherited?.backgroundColor;

    assert(
      resolvedBg != null,
      'AdaptiveText requires either a [backgroundColor] prop or an '
      '[AdaptiveTextTheme] ancestor in the widget tree.',
    );

    final resolvedPalette = palette ?? inherited?.palette;
    final resolvedAlgorithm =
        algorithm ?? inherited?.algorithm ?? ContrastAlgorithm.wcag;

    final Color adaptiveColor = getAdaptiveColor(
      resolvedBg!,
      palette: resolvedPalette,
      algorithm: resolvedAlgorithm,
    );

    // 3. Merge the adaptive color into the provided style (if any).
    //    An explicit TextStyle.color always wins over the adaptive color.
    final TextStyle effectiveStyle = (style ?? const TextStyle()).copyWith(
      color: style?.color ?? adaptiveColor,
    );

    return Text(
      data,
      style: effectiveStyle,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
