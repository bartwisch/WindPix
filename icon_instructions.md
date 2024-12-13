# Creating an App Icon for WindPix

To create a proper app icon, you'll need to create images in the following sizes and save them in the `AppIcon.iconset` folder:

1. Required icon files and sizes:
   - icon_16x16.png (16×16)
   - icon_16x16@2x.png (32×32)
   - icon_32x32.png (32×32)
   - icon_32x32@2x.png (64×64)
   - icon_128x128.png (128×128)
   - icon_128x128@2x.png (256×256)
   - icon_256x256.png (256×256)
   - icon_256x256@2x.png (512×512)
   - icon_512x512.png (512×512)
   - icon_512x512@2x.png (1024×1024)

2. After creating these images, convert them to .icns:
   ```bash
   cd WindPixMVP
   iconutil -c icns AppIcon.iconset
   ```

3. Add to Info.plist:
   The following entry will be added to Info.plist:
   ```xml
   <key>CFBundleIconFile</key>
   <string>AppIcon</string>
   ```

## Icon Design Guidelines

1. Keep it simple and recognizable even at small sizes
2. Use the macOS icon grid for proper proportions
3. Consider both light and dark backgrounds
4. Make sure the icon looks good in both color and monochrome

## Tools for Creating Icons

You can use these tools to create your icon:
- Adobe Photoshop
- Sketch
- Figma
- Pixelmator Pro
- Icon Set Creator (Mac App Store)

## Testing the Icon

After creating the icon:
1. Build the app bundle
2. Copy AppIcon.icns to WindPix.app/Contents/Resources/
3. Update Info.plist
4. The icon should appear in Finder and the Dock
