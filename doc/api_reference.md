# API Reference

## Functions

### `getAdaptiveColor`
```dart
Color getAdaptiveColor(
  Color background, {
  List<Color>? palette,
  ContrastAlgorithm algorithm = ContrastAlgorithm.wcag,
})
```
Returns the color from `palette` (or black/white if null) with the highest contrast against `background`.

---

### `getContrastRatio`
```dart
double getContrastRatio(Color foreground, Color background)
```
WCAG 2.1 contrast ratio between two colors. Range: `[1, 21]`. AA requires ≥ 4.5.

---

### `getLuminance`
```dart
double getLuminance(Color color)
```
WCAG 2.1 relative luminance. Range: `[0, 1]`.

---

### `isLight` / `isDark`
```dart
bool isLight(Color color)
bool isDark(Color color)
```
Returns whether the color is perceptually light or dark (threshold: luminance > 0.179).

---

### `meetsWcag`
```dart
bool meetsWcag(Color foreground, Color background, {WcagLevel level = WcagLevel.aa})
```
Returns true if the pair meets WCAG AA (4.5:1) or AAA (7:1).

---

### `getApcaContrast`
```dart
double getApcaContrast(Color text, Color background)
```
APCA Lc contrast value. Positive = dark text on light bg. |Lc| ≥ 60 is generally readable.

---

## Widgets

### `AdaptiveText`
Drop-in replacement for Flutter's `Text`. Resolves text color from `backgroundColor` or inherited `AdaptiveTextTheme`.

| Prop | Type | Default |
|---|---|---|
| `backgroundColor` | `Color?` | null (reads from theme) |
| `palette` | `List<Color>?` | null → black/white |
| `algorithm` | `ContrastAlgorithm` | `.wcag` |
| `style` | `TextStyle?` | null |
| All `Text` props | — | forwarded |

---

### `AdaptiveTextTheme`
InheritedWidget. Propagates `backgroundColor` (and optionally `palette`, `algorithm`) to all `AdaptiveText` descendants.

```dart
AdaptiveTextTheme.of(context)      // throws if not found
AdaptiveTextTheme.maybeOf(context) // returns null if not found
```

---

## Enums

```dart
enum ContrastAlgorithm { wcag, apca }
enum WcagLevel { aa, aaa }
```

## Color Extensions

| Extension | Returns | Description |
|---|---|---|
| `.adaptiveTextColor` | `Color` | Best of black/white |
| `.adaptiveTextColorFrom(palette)` | `Color` | Best from palette |
| `.isLight` | `bool` | luminance > 0.179 |
| `.isDark` | `bool` | !isLight |
| `.relativeLuminance` | `double` | WCAG luminance 0–1 |
| `.contrastRatioWith(other)` | `double` | WCAG ratio |
| `.meetsWcagWith(other, level:)` | `bool` | AA/AAA pass |
| `.apcaContrastOn(bg)` | `double` | APCA Lc |
