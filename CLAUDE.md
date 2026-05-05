# adaptive_text — AI Context

## What this package does
`adaptive_text` automatically selects a legible text color (black, white, or any palette color) given a background color. It uses the WCAG 2.1 relative luminance formula with an optional APCA (WCAG 3.0) mode.

## Package structure
```
adaptive-text/
├── lib/
│   ├── adaptive_text.dart        ← public barrel export
│   └── src/
│       ├── algorithm.dart        ← core WCAG/APCA math (pure functions)
│       ├── extensions.dart       ← Color extension methods
│       ├── adaptive_text_widget.dart   ← AdaptiveText widget
│       ├── adaptive_text_theme.dart    ← AdaptiveTextTheme InheritedWidget
│       └── context_extension.dart      ← BuildContext.adaptiveForegroundColor
├── test/
│   └── adaptive_text_test.dart   ← full unit + widget tests
├── example/
│   └── lib/
│       ├── main.dart             ← app entry point + navigation
│       └── screens/
│           ├── home_screen.dart
│           ├── widget_demo_screen.dart
│           ├── palette_demo_screen.dart
│           ├── extension_demo_screen.dart
│           └── apca_demo_screen.dart
├── doc/                          ← additional documentation
├── assets/                       ← package assets (if any)
├── .github/workflows/ci.yml      ← CI pipeline
├── pubspec.yaml
├── analysis_options.yaml
├── CHANGELOG.md
├── LICENSE
└── README.md
```

## Core algorithm (algorithm.dart)
- `getLuminance(Color)` — WCAG 2.1 relative luminance (0–1)
- `getContrastRatio(Color, Color)` — WCAG contrast ratio (1–21)
- `getAdaptiveColor(Color bg, {List<Color>? palette, ContrastAlgorithm})` — main entry point
- `getApcaContrast(Color text, Color bg)` — APCA Lc value
- `isLight(Color)` / `isDark(Color)` — threshold 0.179
- `meetsWcag(Color, Color, {WcagLevel})` — AA (4.5:1) or AAA (7:1)

## Key design decisions
- Threshold 0.179 is the exact WCAG 2.1 crossover point — guaranteed ≥ 4.5:1 for both black and white
- Empty palette falls back to black/white automatically
- Explicit `style.color` on AdaptiveText always wins over adaptive resolution
- `AdaptiveTextTheme` uses InheritedWidget (not Provider) to keep zero pub dependencies
- APCA implementation follows the APCA-W3 spec (Lc values, not ratio)

## Enums
```dart
enum ContrastAlgorithm { wcag, apca }
enum WcagLevel { aa, aaa }
```

## Running tests
```bash
flutter test
```

## Publishing
```bash
dart pub publish --dry-run
dart pub publish
```
