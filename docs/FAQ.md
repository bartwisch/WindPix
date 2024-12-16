# Frequently Asked Questions (FAQ)

## General Questions

### What is WindPix?
WindPix is a multi-platform utility that makes it easy to capture and share screenshots directly in Windsurf. It's designed to streamline the process of sharing visual information during conversations.

### Is WindPix free to use?
Yes, WindPix is completely free and open source.

## Installation

### Needed Permissions
- **macOS**: Enable System Settings / Privacy & Security / Screen and System Audio Recording for Windsurf
- **Windows**: No special permissions required.
- **Linux**: No special permissions required.

### Why does WindPix need screen recording permission?
Screen recording permission is required to capture screenshots of your screen on macOS. This is a macOS security requirement for any application that needs to capture screen content.

### Why does WindPix need accessibility permission?
Accessibility permission is needed on macOS to support global hotkeys (like ⌘P) that work from any application.

### How do I install WindPix on different platforms?
- **macOS**: Download the `.dmg` installer and follow the on-screen instructions.
- **Windows**: Download the `.exe` installer and follow the setup wizard.
- **Linux**: Download the [WindPix-1.0.0-arm64.AppImage](../windpix-electron/dist/WindPix-1.0.0-arm64.AppImage) installer and make it executable using the command: `chmod +x WindPix-1.0.0-arm64.AppImage` before running it.

## Usage

### How do I capture a screenshot?
Press ⌘P (macOS) or Ctrl+P (Windows/Linux) from any application to start a capture. You can then either:
1. Click and drag to select an area, or
2. Press Space to capture the entire screen

### Can I change the hotkey?
Currently, the hotkey is fixed to ⌘P (macOS) and Ctrl+P (Windows/Linux). Customizable hotkeys are planned for a future release.

### What happens if Windsurf isn’t running?
WindPix will automatically launch Windsurf for you if it’s not already running.

### Can I use WindPix with other applications?
Currently, WindPix is designed specifically for use with Windsurf. Support for other applications may be considered in future releases.

## Troubleshooting

### The hotkey isn’t working
1. Check that WindPix is running (look for the icon in your menu bar or system tray)
2. Verify that you’ve granted accessibility permissions in System Preferences (macOS) or check for any conflicts with other applications (Windows/Linux)
3. Try restarting WindPix
4. If the issue persists, check if another application is using the same hotkey

### Screenshots aren’t being captured
1. Ensure you’ve granted screen recording permission (macOS)
2. Try restarting WindPix
3. If using multiple displays, make sure you’re capturing from the correct screen

### WindPix isn’t connecting to Windsurf
1. Check that Windsurf is installed correctly
2. Verify that automation permissions are granted (macOS)
3. Try restarting both applications

## Support

### How do I report a bug?
1. Check if the issue is already reported in our [GitHub Issues](https://github.com/bartwisch/windpix/issues)
2. If not, create a new issue using our bug report template
3. Include as much detail as possible, including:
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - System information

### How do I request a feature?
1. Check our [GitHub Issues](https://github.com/bartwisch/windpix/issues) for similar requests
2. If your idea is new, create a feature request using our template
3. Describe the feature and explain why it would be valuable

### Where can I get help?
- Check this FAQ
- Review our [documentation](https://github.com/bartwisch/windpix/docs)
- Create a [GitHub Issue](https://github.com/bartwisch/windpix/issues)
- Join our community discussions
