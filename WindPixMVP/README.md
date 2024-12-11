# WindPix MVP v0.1.0

A command-line tool that automates the process of taking and sharing screenshots with Windsurf.

## Features

- Global hotkey (⌘⌥P) to trigger full screen screenshot
- Automatic screenshot capture
- Automatic pasting into Windsurf chat
- Automatic message sending

## Requirements

- macOS 11.0 or later
- Xcode 13.0 or later
- Swift 5.9 or later

## Building

To build the project, run:

```bash
swift build
```

## Running

To run the built executable:

```bash
.build/debug/WindPixMVP
```

## Permissions Required

The app requires the following permissions:

- Screen Recording (for taking screenshots)
- Accessibility (for simulating keyboard events)
- Input Monitoring (for global hotkey)

## Development Status

This is an MVP (Minimum Viable Product) version that implements the basic functionality of capturing and sharing screenshots. Future versions will include:

- GUI/Status bar menu
- Settings/Preferences
- Custom delays
- Error handling
- Installer
- Auto-updates
- Multiple monitor support
- Custom screenshot area
