import type { ColorValue } from 'react-native';
import { processColor, StyleSheet } from 'react-native';
import type { Rgb } from './algorithm';
import {
  ContrastAlgorithm,
  getAdaptiveColor,
  getApcaContrast,
  getContrastRatio,
  getLuminance,
  isDark,
  isLight,
  meetsWcag,
  type WcagLevel,
} from './algorithm';

function clampByte(n: number): number {
  return Math.max(0, Math.min(255, Math.round(n)));
}

/** Pack sRGB into `#rrggbb` for React Native styles. */
export function rgbToHex(rgb: Rgb): string {
  const r = clampByte(rgb.r);
  const g = clampByte(rgb.g);
  const b = clampByte(rgb.b);
  return `#${[r, g, b]
    .map((x) => x.toString(16).padStart(2, '0'))
    .join('')}`;
}

/**
 * Decode a React Native processed color integer (typically 0xAARRGGBB) to RGB.
 * Mirrors how RN represents opaque colors after processColor.
 */
export function intToRgb(argb: number): Rgb {
  const u = argb >>> 0;
  return {
    r: (u >> 16) & 0xff,
    g: (u >> 8) & 0xff,
    b: u & 0xff,
  };
}

/** Parse common hex strings (#rgb, #rrggbb, #rrggbbaa); alpha is dropped. */
export function hexToRgb(hex: string): Rgb {
  let h = hex.trim();
  if (h.startsWith('#')) {
    h = h.slice(1);
  }
  if (h.length === 3) {
    h = h
      .split('')
      .map((c) => c + c)
      .join('');
  }
  if (h.length === 8) {
    h = h.slice(0, 6);
  }
  if (h.length !== 6) {
    throw new Error(`Invalid hex color: ${hex}`);
  }
  const n = parseInt(h, 16);
  if (Number.isNaN(n)) {
    throw new Error(`Invalid hex color: ${hex}`);
  }
  return {
    r: (n >> 16) & 0xff,
    g: (n >> 8) & 0xff,
    b: n & 0xff,
  };
}

/** Convert React Native ColorValue to sRGB (uses processColor). */
export function colorValueToRgb(color: ColorValue): Rgb {
  if (typeof color === 'string') {
    const s = color.trim();
    if (s.startsWith('#')) {
      return hexToRgb(s);
    }
  }
  const processed = processColor(color);
  if (processed == null) {
    throw new Error(`Unsupported or invalid color: ${String(color)}`);
  }
  return intToRgb(processed as number);
}

/** Best WCAG black/white (or palette) as hex for this background. */
export function adaptiveTextHex(
  background: ColorValue,
  options?: {
    palette?: ColorValue[] | null;
    algorithm?: (typeof ContrastAlgorithm)[keyof typeof ContrastAlgorithm];
  },
): string {
  const bg = colorValueToRgb(background);
  const pal = options?.palette?.map(colorValueToRgb) ?? undefined;
  const rgb = getAdaptiveColor(bg, {
    palette: pal,
    algorithm: options?.algorithm,
  });
  return rgbToHex(rgb);
}

/** Same resolution as AdaptiveText; returns `#rrggbb`. */
export function adaptiveTextHexFromRgb(
  background: Rgb,
  options?: {
    palette?: Rgb[] | null;
    algorithm?: (typeof ContrastAlgorithm)[keyof typeof ContrastAlgorithm];
  },
): string {
  return rgbToHex(
    getAdaptiveColor(background, {
      palette: options?.palette,
      algorithm: options?.algorithm,
    }),
  );
}

/** Read `color` from a style object (arrays flattened like RN). */
export function getExplicitColorFromStyle(
  style: import('react-native').StyleProp<import('react-native').TextStyle>,
): ColorValue | undefined {
  const flat = StyleSheet.flatten(style);
  return flat?.color;
}

/**
 * Ergonomic helpers mirroring Flutter’s `AdaptiveColorExtension` (no prototype patch).
 */
export const adaptiveRgb = {
  adaptiveTextColor(bg: Rgb): Rgb {
    return getAdaptiveColor(bg);
  },
  adaptiveTextColorFrom(
    bg: Rgb,
    palette: Rgb[],
    algorithm?: (typeof ContrastAlgorithm)[keyof typeof ContrastAlgorithm],
  ): Rgb {
    return getAdaptiveColor(bg, { palette, algorithm });
  },
  isLight,
  isDark,
  relativeLuminance: getLuminance,
  contrastRatioWith(a: Rgb, b: Rgb): number {
    return getContrastRatio(a, b);
  },
  meetsWcagWith(
    a: Rgb,
    b: Rgb,
    opts?: { level?: WcagLevel },
  ): boolean {
    return meetsWcag(a, b, opts);
  },
  apcaContrastOn(text: Rgb, background: Rgb): number {
    return getApcaContrast(text, background);
  },
};
