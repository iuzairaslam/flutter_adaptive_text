import React, { createContext, useContext, useMemo } from 'react';
import type { ColorValue } from 'react-native';
import type { ContrastAlgorithm } from './algorithm';

export interface AdaptiveTextThemeData {
  backgroundColor: ColorValue;
  palette?: ColorValue[] | null;
  algorithm: ContrastAlgorithm;
}

const Ctx = createContext<AdaptiveTextThemeData | null>(null);

export interface AdaptiveTextThemeProps {
  backgroundColor: ColorValue;
  palette?: ColorValue[] | null;
  algorithm?: ContrastAlgorithm;
  children: React.ReactNode;
}

export function AdaptiveTextTheme({
  backgroundColor,
  palette,
  algorithm = 'wcag',
  children,
}: AdaptiveTextThemeProps): React.ReactElement {
  const value = useMemo<AdaptiveTextThemeData>(
    () => ({
      backgroundColor,
      palette,
      algorithm,
    }),
    [backgroundColor, palette, algorithm],
  );
  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useAdaptiveTextTheme(): AdaptiveTextThemeData | null {
  return useContext(Ctx);
}
