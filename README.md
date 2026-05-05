# adaptive_text

**Flutter Package · v1.0.0 · [pub.dev](https://pub.dev/packages/adaptive_text)**  
[![Pub](https://img.shields.io/pub/v/adaptive_text.svg)](https://pub.dev/packages/adaptive_text)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/iuzairaslam/adaptive_text/blob/main/LICENSE)
[![style: flutter lints](https://img.shields.io/badge/style-flutter__lints-blue)](https://pub.dev/packages/flutter_lints)
[![Flutter](https://img.shields.io/badge/Flutter-3.10%2B-blue?logo=flutter)](https://flutter.dev)

| Constraint | Detail |
| --- | --- |
| Flutter | 3.10+ |
| Contrast | WCAG 2.1 AA / AAA |
| Optional | APCA (WCAG 3.0 proposal) |
| Dependencies | **Zero** pub packages — Flutter SDK only |
| License | MIT |

---

## 1. Overview

`adaptive_text` is a Flutter package that automatically selects the most legible text color given any background color. Instead of hard-coding white or black text, developers pass a background `Color` and the package returns the correct foreground — black, white, or the best match from a custom design-system palette — using WCAG 2.1 contrast mathematics.

The package exists because many ecosystem options are abandoned (4+ years old), support only pure black/white with no palette, or are bundled inside a larger framework. **adaptive_text** is a standalone, zero-dependency, TypeScript-first-quality Dart library.

---

## 2. Scope

### What it does

- Accepts any background `Color` and returns a legible text `Color`.
- **Black / white** auto-selection via the WCAG 2.1 luminance formula — **always ≥ 4.5:1** contrast ratio for that fallback pair.
- **Palette-aware** selection — pass brand colors; the highest-contrast candidate wins.
- **WCAG 2.1 AA** (4.5:1) and **AAA** (7:1) compliance checking.
- **APCA** support — perceptual contrast model proposed for WCAG 3.0.
- Drop-in **`AdaptiveText`** widget replacing Flutter’s `Text`.
- **`AdaptiveTextTheme`** (`InheritedWidget`) to propagate background (and optional palette / algorithm) down a subtree.
- **`AdaptiveColorExtension`** on **`Color`**: `.adaptiveTextColor`, `.adaptiveTextColorFrom`, `.isLight`, `.isDark`, `.relativeLuminance`, `.contrastRatioWith`, `.meetsWcagWith`, `.apcaContrastOn`.
- **`BuildContext`** extension: **`adaptiveForegroundColor(...)`** and **`adaptiveTextTheme`** for icons / custom widgets without wrapping everything in **`AdaptiveText`**.

### What it does **not** do

- Does not generate full color palettes or design tokens.
- Does not handle animated backgrounds by itself — pass a new background when the color changes.
- Does not wire into `ThemeData` automatically; use `AdaptiveText` / `AdaptiveTextTheme` explicitly.
- Does not sample **images** — only solid `Color` values.

---

## 3. Core algorithm

The implementation follows [WCAG 2.1 relative luminance and contrast](https://www.w3.org/TR/WCAG21/#dfn-relative-luminance).

| Step | Operation | Detail |
| --- | --- | --- |
| 1 | Normalize channels | \(c \le 0.03928 \rightarrow c/12.92\) else \(((c+0.055)/1.055)^{2.4}\) |
| 2 | Relative luminance | \(L = 0.2126 R + 0.7152 G + 0.0722 B\) |
| 3 | Contrast ratio | \((L_{\mathrm{lighter}} + 0.05) / (L_{\mathrm{darker}} + 0.05)\) |
| 4 | Pick candidate | Highest ratio among palette candidates; fallback black vs white using threshold **L > 0.179** |

The **0.179** threshold is the WCAG 2.1 crossover point for black vs white: it **guarantees ≥ 4.5:1** for both choices across sRGB (stress-tested; worst case around **4.58:1**).

---

## 4. Public API

### Functions

| Function | Returns | Description |
| --- | --- | --- |
| `getAdaptiveColor(bg, {palette?, algorithm?})` | `Color` | Main entry point — best text color. |
| `getContrastRatio(fg, bg)` | `double` | WCAG ratio \[1–21\]. AA needs ≥ 4.5. |
| `getLuminance(color)` | `double` | WCAG relative luminance \[0–1\]. |
| `isLight(color)` / `isDark(color)` | `bool` | Brightness via **0.179** threshold. |
| `meetsWcag(fg, bg, {level?})` | `bool` | AA (4.5:1) or AAA (7:1). |
| `getApcaContrast(text, bg)` | `double` | APCA **Lc**; \(\|Lc\| \ge 60\) is a common readability target. |
| `wcagContrastRatioFromLuminance(lumA, lumB)` | `double` | WCAG ratio from two luminances — skips recomputing **shared** background luminance when scoring many candidates. |

Also exported: `wcagMinimumRatio`, `ContrastAlgorithm`, `WcagLevel`.

### Widgets & theme

| Widget / class | Purpose |
| --- | --- |
| **`AdaptiveText`** | Drop-in `Text` replacement. Takes `backgroundColor` or inherits from theme. All standard `Text` arguments pass through. **`style.color` overrides** adaptive resolution. |
| **`AdaptiveTextTheme`** | Wrap a subtree to propagate `backgroundColor`, optional `palette`, and `algorithm`. Not a `const` constructor (theme data is cached once per instance). |

**`AdaptiveTextThemeData`** — immutable data: `backgroundColor`, `palette?`, `algorithm`. Resolve with `AdaptiveTextTheme.of(context)` or `.maybeOf(context)`.

Descendant **`AdaptiveText`** widgets inherit **`palette`** and **`algorithm`** when their own arguments are omitted (`algorithm` is `ContrastAlgorithm?`; `null` means “use theme / default WCAG”).

### `BuildContext` helpers (`AdaptiveTextBuildContext`)

| Member | Description |
| --- | --- |
| `context.adaptiveTextTheme` | Same as `AdaptiveTextTheme.maybeOf(context)`. |
| `context.adaptiveForegroundColor({backgroundColor?, palette?, algorithm?})` | Same resolution rules as **`AdaptiveText`** — merges overrides with inherited theme. |

### `AdaptiveColorExtension` on `Color`

| Extension | Returns | Description |
| --- | --- | --- |
| `.adaptiveTextColor` | `Color` | Best black/white for **this** background. |
| `.adaptiveTextColorFrom(palette, {algorithm?})` | `Color` | Best palette color for **this** background. |
| `.isLight` / `.isDark` | `bool` | WCAG luminance threshold **0.179**. |
| `.relativeLuminance` | `double` | WCAG luminance \[0–1\]. |
| `.contrastRatioWith(other)` | `double` | WCAG contrast vs `other`. |
| `.meetsWcagWith(other, {level?})` | `bool` | AA or AAA pair check. |
| `.apcaContrastOn(bg)` | `double` | APCA **Lc** vs `bg`. |

### Enums

```dart
enum ContrastAlgorithm { wcag, apca }
enum WcagLevel { aa, aaa } // AA = 4.5:1, AAA = 7:1
```

---

## 5. Usage patterns

### Pattern A — Basic widget

```dart
AdaptiveText('Hello', backgroundColor: Colors.indigo[900]!)
```

Example outcome: **white** text (low luminance background → light text; strong contrast ratio).

### Pattern B — Palette-aware

```dart
AdaptiveText(
  'Hello',
  backgroundColor: myBg,
  palette: [Colors.orange, brandBlue, Colors.white],
)
```

Whichever candidate has the **highest** contrast against `myBg` wins.

### Pattern C — Subtree theme

```dart
AdaptiveTextTheme(
  backgroundColor: dynamicBg,
  palette: brandPalette, // optional — inherited by descendants
  algorithm: ContrastAlgorithm.apca, // optional
  child: Column(
    children: const [
      AdaptiveText('Title'),
      AdaptiveText('Body'),
    ],
  ),
)
```

Set background **once**; **`palette`** / **`algorithm`** propagate the same way when child **`AdaptiveText`** omits them.

### Pattern D — Color extension (no wrapper widget)

```dart
Text('Hi', style: TextStyle(color: myBg.adaptiveTextColor))
```

Use when you only need the `Color`, not `AdaptiveText`.

### Pattern E — APCA (opt-in)

```dart
AdaptiveText(
  'Hi',
  backgroundColor: myBg,
  algorithm: ContrastAlgorithm.apca,
)
```

Or: `getAdaptiveColor(myBg, algorithm: ContrastAlgorithm.apca)`.

Inside **`AdaptiveTextTheme`**, omit **`algorithm`** on **`AdaptiveText`** to inherit APCA from the theme.

### Pattern F — `BuildContext` (icons & custom paint)

```dart
AdaptiveTextTheme(
  backgroundColor: cardBg,
  palette: const [Colors.indigo, Colors.white],
  child: Builder(
    builder: (ctx) => Icon(
      Icons.star_rounded,
      color: ctx.adaptiveForegroundColor(),
    ),
  ),
)
```

---

## 6. Package structure

| Path | Purpose |
| --- | --- |
| `lib/adaptive_text.dart` | Barrel export — single import for consumers. |
| `lib/src/algorithm.dart` | Pure math: luminance, contrast ratio, APCA, palette picker. |
| `lib/src/extensions.dart` | `AdaptiveColorExtension` on `Color`. |
| `lib/src/context_extension.dart` | `BuildContext` helpers (`adaptiveForegroundColor`, `adaptiveTextTheme`). |
| `lib/src/adaptive_text_widget.dart` | `AdaptiveText` widget. |
| `lib/src/adaptive_text_theme.dart` | `AdaptiveTextTheme` + `AdaptiveTextThemeData`. |
| `test/adaptive_text_test.dart` | **30+** unit & widget tests (algorithm, extensions, widgets, theme). |
| `example/lib/main.dart` | Demo app entry. |
| `example/lib/screens/` | Demos: **home**, **widget**, **palette**, **extension**, **APCA**. |
| `.github/workflows/ci.yml` | CI: format, analyze, test, **`dart pub publish --dry-run`**. |

---

## Example app

Multi-platform **`example/`** (mobile, web, desktop):

```bash
cd example
flutter pub get
flutter run
# Desktop: flutter run -d macos    # or windows / linux
```

---

## Installation

```yaml
dependencies:
  adaptive_text: ^1.0.0
```

```dart
import 'package:adaptive_text/adaptive_text.dart';
```

**Publish:** `dart pub publish` (after tests and `dart pub publish --dry-run`).

---

## Repository

[github.com/iuzairaslam/adaptive_text](https://github.com/iuzairaslam/adaptive_text)

---

## License

MIT — see [LICENSE](https://github.com/iuzairaslam/adaptive_text/blob/main/LICENSE).
