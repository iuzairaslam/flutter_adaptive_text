import 'package:flutter/widgets.dart';
import 'algorithm.dart';

/// Holds the configuration shared across a subtree of [AdaptiveText] widgets.
@immutable
class AdaptiveTextThemeData {
  /// Creates an [AdaptiveTextThemeData].
  const AdaptiveTextThemeData({
    required this.backgroundColor,
    this.palette,
    this.algorithm = ContrastAlgorithm.wcag,
  });

  /// The background color that descendant [AdaptiveText] widgets should
  /// evaluate their text color against.
  final Color backgroundColor;

  /// Optional palette of candidate text colors passed down to descendants.
  final List<Color>? palette;

  /// The contrast algorithm used by descendant widgets.
  final ContrastAlgorithm algorithm;

  /// Whether [other] is an [AdaptiveTextThemeData] with the same fields and palette.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdaptiveTextThemeData &&
        other.backgroundColor == backgroundColor &&
        other.algorithm == algorithm &&
        _palettesEqual(other.palette, palette);
  }

  static bool _palettesEqual(List<Color>? a, List<Color>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Hash code consistent with [operator ==] (includes palette contents).
  @override
  int get hashCode => Object.hash(
        backgroundColor,
        algorithm,
        palette == null ? null : Object.hashAll(palette!),
      );
}

/// An [InheritedWidget] that propagates [AdaptiveTextThemeData] down the
/// widget tree.
///
/// Wrap a subtree with [AdaptiveTextTheme] to avoid passing [backgroundColor]
/// (and optionally [palette]) to every individual [AdaptiveText] widget.
///
/// ### Example
/// ```dart
/// AdaptiveTextTheme(
///   backgroundColor: Colors.indigo[900]!,
///   child: Column(
///     children: [
///       AdaptiveText('Title'),         // automatically white
///       AdaptiveText('Subtitle'),      // automatically white
///     ],
///   ),
/// )
/// ```
///
/// ### With palette
/// ```dart
/// AdaptiveTextTheme(
///   backgroundColor: Colors.indigo[900]!,
///   palette: [Colors.orange, Colors.grey[200]!, Colors.yellow],
///   child: AdaptiveText('Brand-colored text'),
/// )
/// ```
class AdaptiveTextTheme extends InheritedWidget {
  /// Creates an [AdaptiveTextTheme].
  ///
  /// Not marked `const` so [themeData] can be cached once per widget instance.
  AdaptiveTextTheme({
    super.key,
    required this.backgroundColor,
    this.palette,
    this.algorithm = ContrastAlgorithm.wcag,
    required super.child,
  }) : themeData = AdaptiveTextThemeData(
          backgroundColor: backgroundColor,
          palette: palette,
          algorithm: algorithm,
        );

  /// The background color to propagate to descendant [AdaptiveText] widgets.
  final Color backgroundColor;

  /// Optional palette of candidate text colors for descendant widgets.
  final List<Color>? palette;

  /// The contrast algorithm to propagate to descendant widgets.
  final ContrastAlgorithm algorithm;

  /// Cached [AdaptiveTextThemeData] for this scope — reused by [maybeOf] / [of].
  final AdaptiveTextThemeData themeData;

  /// Returns the nearest [AdaptiveTextThemeData] from the given [context], or
  /// throws if none is found.
  ///
  /// Use [maybeOf] for a nullable (non-throwing) version.
  static AdaptiveTextThemeData of(BuildContext context) {
    final result = maybeOf(context);
    assert(
      result != null,
      'No AdaptiveTextTheme found in context. '
      'Make sure to wrap your widget tree with an AdaptiveTextTheme.',
    );
    return result!;
  }

  /// Returns the nearest [AdaptiveTextThemeData] from the given [context], or
  /// `null` if none is found.
  static AdaptiveTextThemeData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AdaptiveTextTheme>()
        ?.themeData;
  }

  /// Notifies descendants when [themeData] no longer matches the previous
  /// widget's `themeData` ([oldWidget]).
  @override
  bool updateShouldNotify(AdaptiveTextTheme oldWidget) {
    return themeData != oldWidget.themeData;
  }
}
