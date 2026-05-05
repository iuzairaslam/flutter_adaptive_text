# flutter_adaptive_text

[![Pub](https://img.shields.io/pub/v/flutter_adaptive_text.svg)](https://pub.dev/packages/flutter_adaptive_text)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/iuzairaslam/flutter_adaptive_text/blob/main/LICENSE)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)
[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-blue?logo=flutter)](https://flutter.dev)

A Flutter package that picks a **legible text color** from a **background color**—black, white, or the best match from **your palette**—using **WCAG 2.1** contrast math, with optional **APCA** (WCAG 3.0–style perceptual contrast).

📐 **WCAG 2.1** — relative luminance via [`Color.computeLuminance`](https://api.flutter.dev/flutter/dart-ui/Color/computeLuminance.html), contrast ratio, AA (4.5:1) / AAA (7:1) checks  
🎯 **Black / white fallback** — luminance threshold **0.179** so the auto pair stays **≥ 4.5:1** on typical sRGB backgrounds  
🎨 **Palette-aware** — pass brand colors; the highest-scoring candidate wins (order breaks ties)  
🔬 **APCA opt-in** — `ContrastAlgorithm.apca` for Lc-based scoring where you want perceptual contrast  
🧩 **Drop-in `AdaptiveText`** — same API surface as `Text`; explicit `TextStyle.color` always wins  
🌳 **`AdaptiveTextTheme`** — `InheritedWidget` (no extra pub deps) propagates background, palette, and algorithm  
🔌 **`Color` extensions** — `adaptiveTextColor`, `adaptiveTextColorFrom`, luminance, contrast helpers  
📍 **`BuildContext` helpers** — `adaptiveForegroundColor()` for icons and custom widgets  
📦 **SDK-only runtime** — depends on `flutter` only; no third-party packages at runtime  
🧪 **Example app** — widget, palette, extension, and APCA demos under `example/`

## Demo

Run the bundled example:

```bash
cd example
flutter pub get
flutter run
```

Use **`-d chrome`**, **`-d macos`**, etc., for other targets. Screens cover home, widget usage, palette selection, extensions, and APCA.

## Table of contents

- [Demo](#demo)
- [Installation](#installation)
- [Quick start](#quick-start)
- [`AdaptiveText`](#adaptivetext)
- [`AdaptiveTextTheme`](#adaptivetexttheme)
- [Pure functions (`algorithm`)](#pure-functions-algorithm)
- [`Color` extensions](#color-extensions)
- [`BuildContext` (icons & custom widgets)](#buildcontext-icons--custom-widgets)
- [WCAG vs APCA](#wcag-vs-apca)
- [API reference summary](#api-reference-summary)
- [License](#license)

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_adaptive_text: ^1.0.0
```

Then:

```bash
flutter pub get
```

Import the single public library:

```dart
import 'package:flutter_adaptive_text/flutter_adaptive_text.dart';
```

Requires **Flutter ≥ 3.10** and **Dart ≥ 3.0**.

## Quick start

**One widget — explicit background**

```dart
AdaptiveText(
  'Hello',
  backgroundColor: Colors.indigo.shade900,
)
```

**Palette — best color from your design tokens**

```dart
AdaptiveText(
  'Sale ends today',
  backgroundColor: brandSurface,
  palette: const [Color(0xFFFF6B00), Color(0xFF1E3A5F), Colors.white],
)
```

**Subtree defaults — set background once**

```dart
AdaptiveTextTheme(
  backgroundColor: cardColor,
  palette: const [Colors.indigo, Colors.white],
  child: const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AdaptiveText('Title'),
      AdaptiveText('Subtitle'),
    ],
  ),
)
```

**Plain `Text` — extension only**

```dart
Text(
  'Hello',
  style: TextStyle(color: Colors.indigo.shade900.adaptiveTextColor),
)
```

**Raw color (no widget)**

```dart
final fg = getAdaptiveColor(Colors.indigo.shade900);
final fgPalette = getAdaptiveColor(
  Colors.indigo.shade900,
  palette: const [Colors.amber, Colors.white],
);
```

**APCA instead of WCAG ratio**

```dart
AdaptiveText(
  'APCA mode',
  backgroundColor: surface,
  algorithm: ContrastAlgorithm.apca,
)
```

## `AdaptiveText`

Drop-in replacement for [`Text`](https://api.flutter.dev/flutter/widgets/Text-class.html). Forwards the usual `Text` arguments (`style`, `textAlign`, `maxLines`, …).

| Parameter | Type | Description |
| --- | --- | --- |
| `data` | `String` | Text to display. |
| `backgroundColor` | `Color?` | Background to score against. If `null`, resolved from [`AdaptiveTextTheme`](#adaptivetexttheme). |
| `palette` | `List<Color>?` | Candidate text colors; best contrast wins. `null` → black/white. Empty list → same as black/white fallback. |
| `algorithm` | `ContrastAlgorithm?` | `wcag` (default) or `apca`. `null` → inherit from theme, else WCAG. |
| `style` | `TextStyle?` | If `style.color` is set, that color is used and adaptive resolution is skipped. |

```dart
const AdaptiveText(
  'Read me',
  backgroundColor: Color(0xFF0D47A1),
);
```

## `AdaptiveTextTheme`

Wrap a subtree to provide default `backgroundColor`, optional `palette`, and optional `algorithm`. Implemented with [`InheritedWidget`](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html)—no Provider or similar.

| Class / member | Description |
| --- | --- |
| `AdaptiveTextTheme(...)` | Constructor: `backgroundColor`, optional `palette`, optional `algorithm`, required `child`. |
| `AdaptiveTextThemeData` | Immutable: `backgroundColor`, `palette?`, `algorithm`. |
| `AdaptiveTextTheme.of(context)` | Throws if no ancestor theme. |
| `AdaptiveTextTheme.maybeOf(context)` | `null` if missing. |

Child `AdaptiveText` widgets read missing `backgroundColor` / `palette` / `algorithm` from the nearest theme.

## Pure functions (`algorithm`)

| Function | Returns | Description |
| --- | --- | --- |
| `getAdaptiveColor(bg, {palette, algorithm})` | `Color` | Best foreground for `bg`. |
| `getLuminance(color)` | `double` | WCAG relative luminance **0.0–1.0** (delegates to `color.computeLuminance()`). |
| `getContrastRatio(fg, bg)` | `double` | WCAG contrast ratio **1.0–21.0**. |
| `wcagContrastRatioFromLuminance(lumA, lumB)` | `double` | Ratio from two luminances (handy when scoring many candidates on one `bg`). |
| `isLight` / `isDark` | `bool` | `getLuminance(c) > 0.179` — **not** the same rule as `ThemeData.estimateBrightnessForColor`. |
| `meetsWcag(fg, bg, {level})` | `bool` | AA (4.5:1) or AAA (7:1). |
| `getApcaContrast(text, bg)` | `double` | APCA **Lc** (signed); larger absolute Lc → stronger perceived contrast. |
| `wcagMinimumRatio(level)` | `double` | Threshold for AA or AAA. |

Enums: `ContrastAlgorithm { wcag, apca }`, `WcagLevel { aa, aaa }`.

## `Color` extensions

`AdaptiveColorExtension` on `Color`:

| Getter / method | Returns | Description |
| --- | --- | --- |
| `adaptiveTextColor` | `Color` | Best black or white for this color as background. |
| `adaptiveTextColorFrom(palette, {algorithm})` | `Color` | Best palette entry for this background. |
| `isLight` / `isDark` | `bool` | Luminance vs **0.179**. |
| `relativeLuminance` | `double` | Same as `getLuminance(this)`. |
| `contrastRatioWith(other)` | `double` | WCAG ratio vs `other`. |
| `meetsWcagWith(other, {level})` | `bool` | Pair check. |
| `apcaContrastOn(bg)` | `double` | APCA Lc vs `bg`. |

## `BuildContext` (icons & custom widgets)

Import is included in `package:flutter_adaptive_text/flutter_adaptive_text.dart`.

| Member | Description |
| --- | --- |
| `context.adaptiveTextTheme` | `AdaptiveTextThemeData?` — same as `AdaptiveTextTheme.maybeOf`. |
| `context.adaptiveForegroundColor({backgroundColor, palette, algorithm})` | Resolves a foreground `Color` like `AdaptiveText`, merging overrides with inherited theme. |

```dart
AdaptiveTextTheme(
  backgroundColor: tileColor,
  child: Builder(
    builder: (context) => Icon(
      Icons.check_circle,
      color: context.adaptiveForegroundColor(),
    ),
  ),
)
```

## WCAG vs APCA

| | WCAG 2.1 (default) | APCA (`ContrastAlgorithm.apca`) |
| --- | --- | --- |
| Metric | Contrast ratio **1–21** | **Lc** (perceptual, signed) |
| Selection in `getAdaptiveColor` | Maximize ratio | Maximize absolute `getApcaContrast` Lc |
| Typical readability | AA: ratio **≥ 4.5** | Often **Lc magnitude ≥ 60** as a rough target (context-dependent) |

Use WCAG for alignment with WCAG 2.x audits; use APCA when you standardize on WCAG 3.0–style tooling.

## API reference summary

**Widgets**

| Widget | Role |
| --- | --- |
| `AdaptiveText` | `Text` with adaptive `Color` from `backgroundColor` / theme / palette / algorithm. |
| `AdaptiveTextTheme` | Supplies defaults via `InheritedWidget`. |

**Theme data**

| Field | Type | Notes |
| --- | --- | --- |
| `backgroundColor` | `Color` | Required for meaningful defaults. |
| `palette` | `List<Color>?` | Optional inherited candidates. |
| `algorithm` | `ContrastAlgorithm` | Default `wcag`. |

**Extension summary** — see [`Color` extensions](#color-extensions) table above.

Full API reference: [pub.dev documentation](https://pub.dev/documentation/flutter_adaptive_text/latest/).

## License

MIT — see [LICENSE](https://github.com/iuzairaslam/flutter_adaptive_text/blob/main/LICENSE).

Repository: [github.com/iuzairaslam/flutter_adaptive_text](https://github.com/iuzairaslam/flutter_adaptive_text)
