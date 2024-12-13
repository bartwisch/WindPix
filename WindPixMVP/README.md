# WindPix MVP v0.1.0

A macOS utility that streamlines the process of taking and sharing screenshots within the Windsurf application.

## Features

- Global hotkey (⌘P) to trigger screenshot
- Area selection or full screen capture
- Screenshot preview and control panel
- Automatic Windsurf integration
- System tray controls and settings

## Requirements

- macOS 11.0 or later
- [Windsurf](https://www.codeium.com/windsurf) installed
- Screen Recording permission
- Accessibility permission
- Input Monitoring permission

## Installation

### Option 1: Download and Run (Recommended)
1. Download the latest release from the [Releases page](https://github.com/bartwisch/windpix/releases)
2. Extract `WindPix.zip`
3. Move `WindPix.app` to your Applications folder
4. Double-click to run
5. If you see a security warning:
   - Open System Preferences > Security & Privacy
   - Click "Open Anyway" to allow the app to run

### Option 2: Build from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/bartwisch/windpix.git
   cd windpix/WindPixMVP
   ```

2. Build the project:
   ```bash
   swift build -c release
   ```

3. Create the app bundle:
   ```bash
   mkdir -p WindPix.app/Contents/MacOS
   cp .build/release/WindPixMVP WindPix.app/Contents/MacOS/WindPix
   ```

## Setting Up Permissions

WindPix requires several permissions to function properly:

1. **Screen Recording**
   - System Preferences > Security & Privacy > Privacy > Screen Recording
   - Add WindPix to the list

2. **Accessibility**
   - System Preferences > Security & Privacy > Privacy > Accessibility
   - Add WindPix to the list

3. **Input Monitoring**
   - System Preferences > Security & Privacy > Privacy > Input Monitoring
   - Add WindPix to the list

## Usage

1. Launch WindPix - you'll see a wind icon (🌬) in your system tray
2. Click the icon to access settings:
   - Use Area Selection: Toggle between area/full screen capture
   - Focus Chat Before Paste: Automatically focus chat window
   - Auto-close with Windsurf: Close WindPix when Windsurf closes
3. Press ⌘P to take a screenshot
4. Use the control panel to:
   - Accept: Send to Windsurf
   - Redo: Take another screenshot
   - Cancel: Abort the operation

## Support

For issues, suggestions, or contributions:
- Open an [issue](https://github.com/bartwisch/windpix/issues)
- Submit a [pull request](https://github.com/bartwisch/windpix/pulls)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
