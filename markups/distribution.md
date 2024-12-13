# Distributing WindPix

To distribute WindPix to other users, follow these steps:

## For Developers (Creating the Distribution)

1. Build the release version:
   ```bash
   cd WindPixMVP
   swift build -c release
   ```

2. Create an App Bundle:
   ```bash
   # Create the app bundle structure
   mkdir -p WindPix.app/Contents/MacOS
   mkdir -p WindPix.app/Contents/Resources
   
   # Copy the built executable
   cp .build/release/WindPixMVP WindPix.app/Contents/MacOS/WindPix
   
   # Copy instructions.md to Resources
   cp ../instructions.md WindPix.app/Contents/Resources/
   ```

3. Create Info.plist:
   Create a file at `WindPix.app/Contents/Info.plist` with the following content:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>CFBundleExecutable</key>
       <string>WindPix</string>
       <key>CFBundleIdentifier</key>
       <string>com.hugo.windpix</string>
       <key>CFBundleName</key>
       <string>WindPix</string>
       <key>CFBundlePackageType</key>
       <string>APPL</string>
       <key>CFBundleShortVersionString</key>
       <string>1.0</string>
       <key>LSMinimumSystemVersion</key>
       <string>10.15</string>
       <key>LSUIElement</key>
       <true/>
   </dict>
   </plist>
   ```

4. Create a ZIP archive:
   ```bash
   zip -r WindPix.zip WindPix.app
   ```

## For Users (Installing the App)

1. Download the WindPix.zip file
2. Extract the ZIP file
3. Move WindPix.app to your Applications folder
4. When first launching the app:
   - Right-click on WindPix.app and select "Open"
   - Click "Open" in the security dialog that appears
   - Grant the necessary permissions when prompted:
     * Screen Recording (for taking screenshots)
     * Accessibility (for keyboard shortcuts)

## Requirements

- macOS 10.15 or later
- Windsurf IDE installed

## Notes

- The app is currently unsigned, so users will need to explicitly allow it to run
- The app requires Windsurf IDE to be running
- Make sure to grant all requested permissions for full functionality

## Support

For support or questions, contact: bartwisch666@gmail.com
