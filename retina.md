# Retina Display Support in WindPix

This document explains how WindPix handles retina displays to ensure high-quality screenshots on high-DPI screens.

## Overview

On retina displays, pixel density is higher than standard displays, requiring special handling to capture accurate screenshots. WindPix uses Electron's built-in scaling factor to properly handle retina displays.

## Implementation Details

### 1. Getting the Scale Factor

```javascript
const primaryDisplay = screen.getPrimaryDisplay();
const scaleFactor = primaryDisplay.scaleFactor;
```

The `scaleFactor` is provided by Electron's screen API. On retina displays, this value is typically 2.0, meaning each logical pixel corresponds to 4 physical pixels (2x2).

### 2. Scaling Screenshot Dimensions

When capturing screenshots, the dimensions need to be adjusted for the display's scale factor:

```javascript
const sources = await desktopCapturer.getSources({
  types: ['screen'],
  thumbnailSize: {
    width: primaryDisplay.size.width * scaleFactor,
    height: primaryDisplay.size.height * scaleFactor
  }
});
```

### 3. Scaling Selection Bounds

When the user selects an area to screenshot, the selection bounds need to be scaled to match the retina display:

```javascript
const scaledBounds = {
  x: Math.round(bounds.x * scaleFactor),
  y: Math.round(bounds.y * scaleFactor),
  width: Math.round(bounds.width * scaleFactor),
  height: Math.round(bounds.height * scaleFactor)
};
```

This ensures that:
- The coordinates (x, y) match the actual pixel positions on the retina display
- The dimensions (width, height) capture the full resolution of the selected area

## Why This Matters

Without proper retina display handling:
1. Screenshots would appear blurry or pixelated on retina displays
2. Selected areas wouldn't match the actual screen coordinates
3. The resulting images would be at half the expected resolution

The current implementation ensures that screenshots are:
- Captured at full retina resolution
- Properly positioned based on user selection
- Saved with the correct dimensions and quality
