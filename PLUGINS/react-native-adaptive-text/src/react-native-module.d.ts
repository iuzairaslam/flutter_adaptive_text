/**
 * Minimal typings so this library compiles without pulling all of react-native
 * into devDependencies. Real apps supply react-native types at compile time.
 */
declare module 'react-native' {
  import type { ComponentType, ReactNode } from 'react';

  export type ColorValue = string | number;

  export type TextStyle = {
    color?: ColorValue;
    [key: string]: unknown;
  };

  export type StyleProp<T> = T | T[] | undefined | null | readonly (T | undefined | null)[];

  export interface TextProps {
    style?: StyleProp<TextStyle>;
    children?: ReactNode;
  }

  export const Text: ComponentType<TextProps>;

  export const StyleSheet: {
    flatten<T>(style?: StyleProp<T> | null): T | undefined;
  };

  /** Returns packed sRGB (opaque) as number; shape varies by platform. */
  export function processColor(color: ColorValue | object): number | null | undefined;
}
