import {
  BLACK,
  WHITE,
  ContrastAlgorithm,
  WcagLevel,
  getAdaptiveColor,
  getContrastRatio,
  getLuminance,
  isDark,
  isLight,
  meetsWcag,
  wcagContrastRatioFromLuminance,
  wcagMinimumRatio,
} from '../algorithm';

describe('getLuminance', () => {
  it('black is 0', () => {
    expect(getLuminance(BLACK)).toBeCloseTo(0, 10);
  });
  it('white is 1', () => {
    expect(getLuminance(WHITE)).toBeCloseTo(1, 6);
  });
  it('mid grey ~0.2158', () => {
    expect(getLuminance({ r: 128, g: 128, b: 128 })).toBeCloseTo(0.2158, 3);
  });
  it('pure red', () => {
    expect(getLuminance({ r: 255, g: 0, b: 0 })).toBeCloseTo(0.2126, 3);
  });
});

describe('getContrastRatio', () => {
  it('black on white is 21', () => {
    expect(getContrastRatio(BLACK, WHITE)).toBeCloseTo(21, 2);
  });
  it('wcagContrastRatioFromLuminance matches', () => {
    const indigo = { r: 49, g: 27, b: 146 };
    expect(
      wcagContrastRatioFromLuminance(getLuminance(indigo), getLuminance(WHITE)),
    ).toBeCloseTo(getContrastRatio(indigo, WHITE), 9);
  });
});

describe('isLight / isDark', () => {
  it('white is light', () => expect(isLight(WHITE)).toBe(true));
  it('black is dark', () => expect(isDark(BLACK)).toBe(true));
  it('yellow is light', () => expect(isLight({ r: 255, g: 235, b: 59 })).toBe(true));
});

describe('getAdaptiveColor', () => {
  it('dark bg prefers white text', () => {
    const c = getAdaptiveColor({ r: 49, g: 27, b: 146 });
    expect(c).toEqual(WHITE);
  });
  it('light bg prefers black', () => {
    const c = getAdaptiveColor({ r: 255, g: 235, b: 59 });
    expect(c).toEqual(BLACK);
  });
  it('empty palette falls back to black/white', () => {
    expect(getAdaptiveColor(WHITE, { palette: [] })).toEqual(BLACK);
    expect(getAdaptiveColor(BLACK, { palette: [] })).toEqual(WHITE);
  });
});

describe('meetsWcag', () => {
  it('AA threshold', () => {
    expect(wcagMinimumRatio(WcagLevel.aa)).toBe(4.5);
    expect(meetsWcag(BLACK, WHITE, { level: WcagLevel.aa })).toBe(true);
  });
});

describe('APCA path', () => {
  it('does not throw and returns a candidate', () => {
    const bg = { r: 20, g: 20, b: 20 };
    const c = getAdaptiveColor(bg, {
      palette: [BLACK, WHITE],
      algorithm: ContrastAlgorithm.apca,
    });
    const ok =
      (c.r === BLACK.r && c.g === BLACK.g && c.b === BLACK.b) ||
      (c.r === WHITE.r && c.g === WHITE.g && c.b === WHITE.b);
    expect(ok).toBe(true);
  });
});
