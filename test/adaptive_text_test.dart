import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:adaptive_text/adaptive_text.dart';

void main() {
  // ---------------------------------------------------------------------------
  // getLuminance
  // ---------------------------------------------------------------------------
  group('getLuminance', () {
    test('black has luminance 0', () {
      expect(getLuminance(Colors.black), closeTo(0.0, 1e-10));
    });

    test('white has luminance 1', () {
      expect(getLuminance(Colors.white), closeTo(1.0, 1e-6));
    });

    test('mid-grey is approximately 0.2', () {
      // #808080 ≈ 0.2158
      expect(getLuminance(const Color(0xFF808080)), closeTo(0.2158, 0.001));
    });

    test('sRGB pure red (#FF0000) has known luminance', () {
      expect(getLuminance(const Color(0xFFFF0000)), closeTo(0.2126, 0.001));
    });

    test('sRGB pure green (#00FF00) has known luminance', () {
      expect(getLuminance(const Color(0xFF00FF00)), closeTo(0.7152, 0.001));
    });

    test('sRGB pure blue (#0000FF) has known luminance', () {
      expect(getLuminance(const Color(0xFF0000FF)), closeTo(0.0722, 0.001));
    });
  });

  // ---------------------------------------------------------------------------
  // getContrastRatio
  // ---------------------------------------------------------------------------
  group('getContrastRatio', () {
    test('black on white is 21:1', () {
      expect(
        getContrastRatio(Colors.black, Colors.white),
        closeTo(21.0, 0.01),
      );
    });

    test('wcagContrastRatioFromLuminance matches getContrastRatio', () {
      expect(
        wcagContrastRatioFromLuminance(
          getLuminance(Colors.indigo[900]!),
          getLuminance(Colors.white),
        ),
        closeTo(
          getContrastRatio(Colors.indigo[900]!, Colors.white),
          1e-9,
        ),
      );
    });

    test('white on black is 21:1 (symmetric)', () {
      expect(
        getContrastRatio(Colors.white, Colors.black),
        closeTo(21.0, 0.01),
      );
    });

    test('same color has ratio 1:1', () {
      expect(getContrastRatio(Colors.blue, Colors.blue), closeTo(1.0, 1e-6));
    });

    test('ratio is always ≥ 1', () {
      final colors = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
      ];
      for (final a in colors) {
        for (final b in colors) {
          expect(getContrastRatio(a, b), greaterThanOrEqualTo(1.0));
        }
      }
    });
  });

  // ---------------------------------------------------------------------------
  // isLight / isDark
  // ---------------------------------------------------------------------------
  group('isLight / isDark', () {
    test('white is light', () => expect(isLight(Colors.white), isTrue));
    test('black is dark', () => expect(isDark(Colors.black), isTrue));

    test('deep purple is dark', () {
      expect(isDark(Colors.deepPurple[900]!), isTrue);
    });

    test('yellow is light', () {
      expect(isLight(Colors.yellow), isTrue);
    });

    test('isLight and isDark are mutually exclusive', () {
      final colors = [
        Colors.white,
        Colors.black,
        Colors.red,
        Colors.blue,
        Colors.yellow,
        Colors.indigo[900]!,
      ];
      for (final c in colors) {
        expect(isLight(c), isNot(isDark(c)));
      }
    });
  });

  // ---------------------------------------------------------------------------
  // getAdaptiveColor — black/white fallback
  // ---------------------------------------------------------------------------
  group('getAdaptiveColor (black/white)', () {
    test('returns white for dark background', () {
      expect(
        getAdaptiveColor(Colors.black),
        equals(const Color(0xFFFFFFFF)),
      );
    });

    test('returns black for light background', () {
      expect(
        getAdaptiveColor(Colors.white),
        equals(const Color(0xFF000000)),
      );
    });

    test('result always meets WCAG AA (4.5:1) for any color', () {
      final backgrounds = [
        Colors.red,
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.teal,
        Colors.indigo[900]!,
        Colors.yellow[600]!,
        Colors.grey[500]!,
        const Color(0xFF123456),
        const Color(0xFFABCDEF),
      ];
      for (final bg in backgrounds) {
        final text = getAdaptiveColor(bg);
        final ratio = getContrastRatio(text, bg);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason:
              'Expected WCAG AA on $bg but got ratio $ratio with text $text',
        );
      }
    });

    test('handles transparent (all zeros) without throwing', () {
      expect(() => getAdaptiveColor(const Color(0x00000000)), returnsNormally);
    });

    test('handles fully opaque white without throwing', () {
      expect(() => getAdaptiveColor(const Color(0xFFFFFFFF)), returnsNormally);
    });
  });

  // ---------------------------------------------------------------------------
  // getAdaptiveColor — palette mode
  // ---------------------------------------------------------------------------
  group('getAdaptiveColor (palette)', () {
    test('picks highest-contrast color from palette', () {
      // White (#fff) contrast against black (21:1) > orange (2.3:1)
      final result = getAdaptiveColor(
        Colors.black,
        palette: [Colors.orange, Colors.white, Colors.yellow],
      );
      expect(result, equals(Colors.white));
    });

    test('picks black from palette when background is white', () {
      final result = getAdaptiveColor(
        Colors.white,
        palette: [Colors.black, Colors.grey[800]!],
      );
      expect(result, equals(Colors.black));
    });

    test('returns first element when palette has one color', () {
      final result = getAdaptiveColor(
        Colors.blue,
        palette: [Colors.red],
      );
      expect(result, equals(Colors.red));
    });

    test('falls back to black/white on empty palette', () {
      final result = getAdaptiveColor(Colors.black, palette: []);
      expect(result, anyOf(equals(Colors.white), equals(Colors.black)));
    });
  });

  // ---------------------------------------------------------------------------
  // meetsWcag
  // ---------------------------------------------------------------------------
  group('meetsWcag', () {
    test('black on white meets AA', () {
      expect(meetsWcag(Colors.black, Colors.white), isTrue);
    });

    test('black on white meets AAA', () {
      expect(
        meetsWcag(Colors.black, Colors.white, level: WcagLevel.aaa),
        isTrue,
      );
    });

    test('light grey on white fails AA', () {
      expect(
        meetsWcag(Colors.grey[300]!, Colors.white),
        isFalse,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Color extensions
  // ---------------------------------------------------------------------------
  group('AdaptiveColorExtension', () {
    test('.adaptiveTextColor returns white on dark bg', () {
      expect(
        Colors.black.adaptiveTextColor,
        equals(const Color(0xFFFFFFFF)),
      );
    });

    test('.adaptiveTextColor returns black on light bg', () {
      expect(
        Colors.white.adaptiveTextColor,
        equals(const Color(0xFF000000)),
      );
    });

    test('.isLight is true for white', () {
      expect(Colors.white.isLight, isTrue);
    });

    test('.isDark is true for black', () {
      expect(Colors.black.isDark, isTrue);
    });

    test('.relativeLuminance matches getLuminance', () {
      final c = Colors.indigo[700]!;
      expect(c.relativeLuminance, closeTo(getLuminance(c), 1e-10));
    });

    test('.contrastRatioWith matches getContrastRatio', () {
      expect(
        Colors.black.contrastRatioWith(Colors.white),
        closeTo(21.0, 0.01),
      );
    });

    test('.meetsWcagWith returns true for AA-passing pair', () {
      expect(Colors.black.meetsWcagWith(Colors.white), isTrue);
    });

    test('.adaptiveTextColorFrom picks best from palette', () {
      const bg = Colors.black;
      final result = bg.adaptiveTextColorFrom([Colors.orange, Colors.white]);
      expect(result, equals(Colors.white));
    });
  });

  // ---------------------------------------------------------------------------
  // APCA contrast (smoke tests — exact values depend on formula version)
  // ---------------------------------------------------------------------------
  group('getApcaContrast', () {
    test('black on white returns large positive Lc', () {
      final lc = getApcaContrast(Colors.black, Colors.white);
      expect(lc, greaterThan(50));
    });

    test('white on black returns large negative Lc', () {
      final lc = getApcaContrast(Colors.white, Colors.black);
      expect(lc, lessThan(-50));
    });

    test('same color returns near-zero Lc', () {
      final lc = getApcaContrast(Colors.red, Colors.red);
      expect(lc.abs(), lessThan(1));
    });
  });

  // ---------------------------------------------------------------------------
  // AdaptiveText widget
  // ---------------------------------------------------------------------------
  group('AdaptiveText widget', () {
    testWidgets('renders white text on dark background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveText(
            'Hello',
            backgroundColor: Colors.black,
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.color, equals(const Color(0xFFFFFFFF)));
    });

    testWidgets('renders black text on light background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveText(
            'Hello',
            backgroundColor: Colors.white,
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.color, equals(const Color(0xFF000000)));
    });

    testWidgets('explicit style.color overrides adaptive color',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveText(
            'Hello',
            backgroundColor: Colors.black,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.color, equals(Colors.red));
    });

    testWidgets('reads background from AdaptiveTextTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveTextTheme(
            backgroundColor: Colors.black,
            child: const AdaptiveText('Hello'),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.color, equals(const Color(0xFFFFFFFF)));
    });

    testWidgets('uses palette when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveText(
            'Hello',
            backgroundColor: Colors.black,
            palette: [Colors.orange, Colors.white],
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.byType(Text));
      // White has higher contrast on black than orange
      expect(textWidget.style?.color, equals(Colors.white));
    });

    testWidgets('inherits palette from AdaptiveTextTheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveTextTheme(
            backgroundColor: Colors.black,
            palette: const [Colors.orange, Colors.white],
            child: const AdaptiveText('Hello'),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.color, equals(Colors.white));
    });

    testWidgets('widget palette overrides theme palette', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveTextTheme(
            backgroundColor: Colors.black,
            palette: const [Colors.orange],
            child: const AdaptiveText(
              'Hello',
              palette: [Colors.orange, Colors.white],
            ),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.color, equals(Colors.white));
    });

    testWidgets('inherits algorithm from AdaptiveTextTheme', (tester) async {
      const bg = Color(0xFF121212);
      final expected = getAdaptiveColor(bg, algorithm: ContrastAlgorithm.apca);
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveTextTheme(
            backgroundColor: bg,
            algorithm: ContrastAlgorithm.apca,
            child: const AdaptiveText('Hello'),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.color, equals(expected));
    });

    testWidgets('throws assertion when no background provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AdaptiveText('Hello'),
        ),
      );
      expect(tester.takeException(), isA<AssertionError>());
    });
  });

  // ---------------------------------------------------------------------------
  // AdaptiveTextTheme
  // ---------------------------------------------------------------------------
  group('AdaptiveTextTheme', () {
    test('AdaptiveTextThemeData equality and hashCode use palette contents',
        () {
      const a = AdaptiveTextThemeData(
        backgroundColor: Colors.black,
        palette: [Colors.white],
      );
      const b = AdaptiveTextThemeData(
        backgroundColor: Colors.black,
        palette: [Colors.white],
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    testWidgets('maybeOf returns null outside theme', (tester) async {
      late AdaptiveTextThemeData? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) {
              result = AdaptiveTextTheme.maybeOf(ctx);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(result, isNull);
    });

    testWidgets('of returns data inside theme', (tester) async {
      late AdaptiveTextThemeData result;
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveTextTheme(
            backgroundColor: Colors.indigo,
            child: Builder(
              builder: (ctx) {
                result = AdaptiveTextTheme.of(ctx);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(result.backgroundColor, equals(Colors.indigo));
    });
  });

  // ---------------------------------------------------------------------------
  // BuildContext extension
  // ---------------------------------------------------------------------------
  group('AdaptiveTextBuildContext', () {
    testWidgets('adaptiveForegroundColor merges with inherited theme',
        (tester) async {
      late Color resolved;
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveTextTheme(
            backgroundColor: Colors.black,
            palette: const [Colors.orange, Colors.white],
            child: Builder(
              builder: (ctx) {
                resolved = ctx.adaptiveForegroundColor();
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(resolved, equals(Colors.white));
    });

    testWidgets('adaptiveTextTheme getter matches maybeOf', (tester) async {
      AdaptiveTextThemeData? data;
      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveTextTheme(
            backgroundColor: Colors.teal,
            child: Builder(
              builder: (ctx) {
                data = ctx.adaptiveTextTheme;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(data?.backgroundColor, equals(Colors.teal));
    });
  });
}
