/// flutter_adaptive_text — Automatically adaptive text color for Flutter.
///
/// Given any background color, this package selects a legible foreground
/// text color. Supports:
/// - Black / white (WCAG 2.1 guaranteed ≥ 4.5:1 contrast)
/// - Palette-aware: picks the best color from your design system
/// - APCA algorithm (WCAG 3.0 proposal) as an opt-in alternative
///
/// ## Quick start
///
/// ```dart
/// import 'package:flutter_adaptive_text/flutter_adaptive_text.dart';
///
/// // Drop-in widget
/// AdaptiveText('Hello', backgroundColor: Colors.indigo[900]!);
///
/// // Color extension
/// Text('Hello', style: TextStyle(color: Colors.indigo[900]!.adaptiveTextColor));
///
/// // Standalone function
/// final color = getAdaptiveColor(Colors.indigo[900]!);
/// ```
library;

// Core algorithm — public API
export 'src/algorithm.dart'
    show
        ContrastAlgorithm,
        WcagLevel,
        getLuminance,
        getContrastRatio,
        getAdaptiveColor,
        getApcaContrast,
        isLight,
        isDark,
        meetsWcag,
        wcagMinimumRatio,
        wcagContrastRatioFromLuminance;

// Color extensions
export 'src/extensions.dart' show AdaptiveColorExtension;

// BuildContext helpers (adaptiveForegroundColor, adaptiveTextTheme getter)
export 'src/context_extension.dart';

// Widgets
export 'src/adaptive_text_theme.dart'
    show AdaptiveTextTheme, AdaptiveTextThemeData;
export 'src/adaptive_text_widget.dart' show AdaptiveText;
