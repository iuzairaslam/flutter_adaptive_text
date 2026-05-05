/**
 * WCAG 2.1 relative luminance + APCA (same constants as flutter_adaptive_text).
 * Colors are sRGB channels 0–255.
 */

export const ContrastAlgorithm = {
  wcag: 'wcag',
  apca: 'apca',
} as const;
export type ContrastAlgorithm =
  (typeof ContrastAlgorithm)[keyof typeof ContrastAlgorithm];

export const WcagLevel = {
  aa: 'aa',
  aaa: 'aaa',
} as const;
export type WcagLevel = (typeof WcagLevel)[keyof typeof WcagLevel];

/** sRGB 8-bit channels (alpha ignored for luminance / APCA). */
export interface Rgb {
  r: number;
  g: number;
  b: number;
}

export const BLACK: Rgb = { r: 0, g: 0, b: 0 };
export const WHITE: Rgb = { r: 255, g: 255, b: 255 };

function linearizeChannel(channel255: number): number {
  const c = channel255 / 255.0;
  if (c <= 0.03928) {
    return c / 12.92;
  }
  return Math.pow((c + 0.055) / 1.055, 2.4);
}

/** WCAG 2.1 relative luminance 0.0–1.0 (same weights as Flutter Color.computeLuminance). */
export function getLuminance(color: Rgb): number {
  const r = linearizeChannel(color.r);
  const g = linearizeChannel(color.g);
  const b = linearizeChannel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

export function wcagContrastRatioFromLuminance(
  lumA: number,
  lumB: number,
): number {
  const lighter = Math.max(lumA, lumB);
  const darker = Math.min(lumA, lumB);
  return (lighter + 0.05) / (darker + 0.05);
}

export function getContrastRatio(foreground: Rgb, background: Rgb): number {
  return wcagContrastRatioFromLuminance(
    getLuminance(foreground),
    getLuminance(background),
  );
}

/** WCAG crossover: guarantees ≥ 4.5:1 vs black and white (not Material brightness). */
export function isLight(color: Rgb): boolean {
  return getLuminance(color) > 0.179;
}

export function isDark(color: Rgb): boolean {
  return !isLight(color);
}

function apcaLinearize(channel255: number): number {
  return Math.pow(channel255 / 255.0, 2.4);
}

/** APCA Lc: positive = dark text on light bg, negative = light on dark. |Lc| ≥ ~60 often “readable”. */
export function getApcaContrast(text: Rgb, background: Rgb): number {
  const sRco = 0.2126729;
  const sGco = 0.7151522;
  const sBco = 0.072175;
  const normBg = 0.56;
  const normTxt = 0.57;
  const revTxt = 0.62;
  const revBg = 0.65;
  const scaleBoW = 1.14;
  const scaleWoB = 1.14;
  const loClip = 0.001;
  const deltaYMin = 0.0005;
  const loBoWOffset = 0.027;
  const loWoBOffset = 0.027;

  const yBgRaw =
    sRco * apcaLinearize(background.r) +
    sGco * apcaLinearize(background.g) +
    sBco * apcaLinearize(background.b);

  const yTxtRaw =
    sRco * apcaLinearize(text.r) +
    sGco * apcaLinearize(text.g) +
    sBco * apcaLinearize(text.b);

  const yBg = yBgRaw < loClip ? loClip : yBgRaw;
  const yTxt = yTxtRaw < loClip ? loClip : yTxtRaw;

  if (Math.abs(yBg - yTxt) < deltaYMin) {
    return 0.0;
  }

  let lc: number;
  if (yBg > yTxt) {
    lc =
      (Math.pow(yBg, normBg) - Math.pow(yTxt, normTxt)) * scaleBoW;
    lc =
      lc < loBoWOffset
        ? lc - loBoWOffset * Math.pow(lc / loBoWOffset, 1.414)
        : lc;
  } else {
    lc =
      (Math.pow(yBg, revBg) - Math.pow(yTxt, revTxt)) * scaleWoB;
    lc =
      lc > -loWoBOffset
        ? lc + loWoBOffset * Math.pow(-lc / loWoBOffset, 1.414)
        : lc;
  }

  return lc * 100.0;
}

export function getAdaptiveColor(
  background: Rgb,
  options?: {
    palette?: Rgb[] | null;
    algorithm?: ContrastAlgorithm;
  },
): Rgb {
  const algorithm = options?.algorithm ?? ContrastAlgorithm.wcag;
  const palette = options?.palette;

  const candidates =
    palette === undefined || palette === null
      ? [BLACK, WHITE]
      : [...palette];

  if (candidates.length === 0) {
    return isLight(background) ? BLACK : WHITE;
  }

  if (algorithm === ContrastAlgorithm.wcag) {
    const bgLum = getLuminance(background);
    let best = candidates[0];
    let bestScore = wcagContrastRatioFromLuminance(
      getLuminance(best),
      bgLum,
    );
    for (let i = 1; i < candidates.length; i++) {
      const c = candidates[i];
      const score = wcagContrastRatioFromLuminance(getLuminance(c), bgLum);
      if (score > bestScore) {
        bestScore = score;
        best = c;
      }
    }
    return best;
  }

  let bestApca = candidates[0];
  let bestApcaScore = Math.abs(getApcaContrast(bestApca, background));
  for (let i = 1; i < candidates.length; i++) {
    const c = candidates[i];
    const score = Math.abs(getApcaContrast(c, background));
    if (score > bestApcaScore) {
      bestApcaScore = score;
      bestApca = c;
    }
  }
  return bestApca;
}

export function wcagMinimumRatio(level: WcagLevel): number {
  switch (level) {
    case WcagLevel.aa:
      return 4.5;
    case WcagLevel.aaa:
      return 7.0;
    default:
      return 4.5;
  }
}

export function meetsWcag(
  foreground: Rgb,
  background: Rgb,
  options?: { level?: WcagLevel },
): boolean {
  const level = options?.level ?? WcagLevel.aa;
  return getContrastRatio(foreground, background) >= wcagMinimumRatio(level);
}
