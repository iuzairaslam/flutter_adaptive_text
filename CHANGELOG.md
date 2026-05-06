## 1.0.1

- Shorten `pubspec.yaml` `description` to meet pub.dev’s 180-character limit (restores full “valid pubspec” / convention points on analysis).

## 1.0.0

- **Package name:** Published as **`flutter_adaptive_text`** — import `package:flutter_adaptive_text/flutter_adaptive_text.dart` (pub.dev: [`flutter_adaptive_text`](https://pub.dev/packages/flutter_adaptive_text)).
- **Overview:** Legible text color from any solid background — WCAG 2.1 math, optional APCA, zero runtime pub dependencies (Flutter SDK only). Flutter **3.10+**, Dart **3.0+**.
- **API:** `getAdaptiveColor`, `getContrastRatio`, `getLuminance`, `isLight` / `isDark`, `meetsWcag`, `getApcaContrast`, `wcagMinimumRatio`, `wcagContrastRatioFromLuminance`; enums `ContrastAlgorithm`, `WcagLevel`.
- **`AdaptiveText`:** Drop-in `Text` replacement; inherits **`palette`** and **`algorithm`** from **`AdaptiveTextTheme`** when omitted (`algorithm` is `ContrastAlgorithm?`; `null` → theme / WCAG).
- **`AdaptiveTextTheme` / `AdaptiveTextThemeData`:** Subtree-wide background, palette, and algorithm; cached **`themeData`**; **`maybeOf`** returns the same instance (no per-lookup allocation). Constructor is **not** `const` (initializer constraint). **`hashCode`** matches palette **contents** (consistent with **`==`**).
- **Extensions:** `AdaptiveColorExtension` on `Color` — `.adaptiveTextColor`, `.adaptiveTextColorFrom`, `.isLight`, `.isDark`, `.relativeLuminance`, `.contrastRatioWith`, `.meetsWcagWith`, `.apcaContrastOn`.
- **`BuildContext`:** `AdaptiveTextBuildContext` — `adaptiveForegroundColor`, `adaptiveTextTheme` (`lib/src/context_extension.dart`).
- **Performance:** WCAG palette path in `getAdaptiveColor` computes background luminance once per call.
- **APCA:** `getApcaContrast` no longer returns **0** for black-on-white due to over-aggressive near-zero luminance handling.
- **Pub / dartdoc:** `dart doc --validate-links` clean (doc references, `See [Text.…]` forwarding docs, override docs); README license links use GitHub URLs; **`.pubignore`** excludes **`doc/api/`**; CI runs **`dart doc --validate-links`** before **`dart pub publish --dry-run`**.
- **Tests:** 50+ unit and widget tests; theme inheritance; context helper; sRGB hex luminance checks.
- **Example:** Full multi-platform **`example/`** (including desktop); widget demo for theme + `context.adaptiveForegroundColor()`; example **`analysis_options`** relaxes demo-only deprecations.
- **CI:** Format, analyze, test, dart doc validation, `dart pub publish --dry-run` on the package; parallel example job.
- **Platforms:** Declared in `pubspec.yaml` (Android, iOS, Linux, macOS, web, Windows).
