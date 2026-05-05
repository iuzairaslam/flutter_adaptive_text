# react-native-adaptive-text

JavaScript port of **`flutter_adaptive_text`**: pick a readable text color (black, white, or the best color from a palette) from a background using **WCAG 2.1** relative luminance and contrast, with an optional **APCA** mode. No native modules.

## Requirements

* **React** ≥ 18  
* **React Native** ≥ 0.71  

## Install

```bash
npm install react-native-adaptive-text
```

From this monorepo (path dependency):

```json
"react-native-adaptive-text": "file:./PLUGINS/react-native-adaptive-text"
```

Run **`npm run build`** inside the plugin folder once (or rely on **`prepublishOnly`** when publishing). Metro can resolve **`"react-native": "src/index.ts"`** for local development.

## Usage

### `AdaptiveText`

```tsx
import { AdaptiveText } from 'react-native-adaptive-text';

<AdaptiveText backgroundColor="#1a237e">Hello</AdaptiveText>;
```

Explicit **`style.color`** wins over the adaptive color (same rule as the Flutter widget).

### Theme (no `backgroundColor` on every line)

```tsx
import { AdaptiveTextTheme, AdaptiveText } from 'react-native-adaptive-text';

<AdaptiveTextTheme backgroundColor="#1a237e" algorithm="wcag">
  <AdaptiveText>Title</AdaptiveText>
  <AdaptiveText>Subtitle</AdaptiveText>
</AdaptiveTextTheme>;
```

### Palette + APCA

```tsx
import {
  AdaptiveText,
  ContrastAlgorithm,
} from 'react-native-adaptive-text';

const brand = ['#ff9800', '#eeeeee', '#ffeb3b'];

<AdaptiveText
  backgroundColor="#000000"
  palette={brand}
  algorithm={ContrastAlgorithm.apca}
>
  Brand text
</AdaptiveText>;
```

### Standalone math (pure RGB 0–255)

```ts
import {
  getAdaptiveColor,
  getLuminance,
  meetsWcag,
  rgbToHex,
} from 'react-native-adaptive-text';

const bg = { r: 26, g: 35, b: 126 };
const rgb = getAdaptiveColor(bg);
const hex = rgbToHex(rgb);
```

### RN color strings

```ts
import { adaptiveTextHex, colorValueToRgb } from 'react-native-adaptive-text';

adaptiveTextHex('#1a237e');
adaptiveTextHex('rgb(0,0,0)', { palette: ['#ff0', '#fff'] });
```

### Hook (icons, `TextInput`, etc.)

```tsx
import { Text } from 'react-native';
import { useAdaptiveForegroundColor, AdaptiveTextTheme } from 'react-native-adaptive-text';

function Subtitle() {
  const color = useAdaptiveForegroundColor();
  return <Text style={{ color }}>Using theme</Text>;
}

<AdaptiveTextTheme backgroundColor="#333">
  <Subtitle />
</AdaptiveTextTheme>;
```

### Extension-style helpers (no prototype patching)

```ts
import { adaptiveRgb } from 'react-native-adaptive-text';

adaptiveRgb.adaptiveTextColor({ r: 0, g: 0, b: 0 });
adaptiveRgb.contrastRatioWith({ r: 0, g: 0, b: 0 }, { r: 255, g: 255, b: 255 });
```

## API parity with Flutter

| Flutter | React Native |
|--------|----------------|
| `getLuminance` | `getLuminance` |
| `getContrastRatio` | `getContrastRatio` |
| `getAdaptiveColor` | `getAdaptiveColor` |
| `getApcaContrast` | `getApcaContrast` |
| `isLight` / `isDark` | `isLight` / `isDark` |
| `meetsWcag` | `meetsWcag` |
| `ContrastAlgorithm` | `ContrastAlgorithm` (`'wcag'` \| `'apca'`) |
| `AdaptiveText` | `AdaptiveText` |
| `AdaptiveTextTheme` | `AdaptiveTextTheme` |
| `BuildContext` extension | `useAdaptiveForegroundColor`, `useAdaptiveTextTheme` |
| `Color` extension | `adaptiveRgb`, `adaptiveTextHex`, `colorValueToRgb` |

## Scripts

```bash
npm install    # uses .npmrc legacy-peer-deps for this package dev tree
npm run build  # emits dist/
npm test       # algorithm unit tests
```

## License

MIT (same as the parent repository).
