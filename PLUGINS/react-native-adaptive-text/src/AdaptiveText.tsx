import React, { useMemo } from 'react';
import {
  Text,
  type ColorValue,
  type StyleProp,
  type TextProps,
  type TextStyle,
} from 'react-native';
import type { ContrastAlgorithm } from './algorithm';
import { adaptiveTextHex, getExplicitColorFromStyle } from './colorUtils';
import { useAdaptiveTextTheme } from './AdaptiveTextTheme';

export interface AdaptiveTextProps extends TextProps {
  /** When omitted, uses the nearest AdaptiveTextTheme. */
  backgroundColor?: ColorValue;
  palette?: ColorValue[] | null;
  algorithm?: ContrastAlgorithm;
}

/**
 * Drop-in Text that picks a legible color from the background (and optional palette).
 * An explicit `style.color` wins, same as flutter_adaptive_text.
 */
export function AdaptiveText({
  backgroundColor,
  palette,
  algorithm,
  style,
  children,
  ...rest
}: AdaptiveTextProps): React.ReactElement {
  const theme = useAdaptiveTextTheme();

  const resolvedBg = backgroundColor ?? theme?.backgroundColor;
  const resolvedPalette = palette ?? theme?.palette;
  const resolvedAlgorithm = algorithm ?? theme?.algorithm ?? 'wcag';

  if (__DEV__ && resolvedBg == null) {
    throw new Error(
      'AdaptiveText requires backgroundColor or an AdaptiveTextTheme ancestor.',
    );
  }

  const adaptiveHex = useMemo(() => {
    if (resolvedBg == null) {
      return '#000000';
    }
    return adaptiveTextHex(resolvedBg, {
      palette: resolvedPalette,
      algorithm: resolvedAlgorithm,
    });
  }, [resolvedBg, resolvedPalette, resolvedAlgorithm]);

  const mergedStyle = useMemo((): StyleProp<TextStyle> => {
    const explicit = getExplicitColorFromStyle(style);
    const color = (explicit ?? adaptiveHex) as ColorValue;
    return [style, { color }] as StyleProp<TextStyle>;
  }, [style, adaptiveHex]);

  return (
    <Text style={mergedStyle} {...rest}>
      {children}
    </Text>
  );
}
