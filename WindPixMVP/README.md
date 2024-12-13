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

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/bartwisch/windpix.git
   cd windpix/WindPixMVP
   ```

2. Build the project:
   ```bash
   swift build
   ```

3. Run the app:
   ```bash
   .build/debug/WindPixMVP
   ```

## Permissions Required

The app requires the following permissions:

- Screen Recording (for taking screenshots)
- Accessibility (for simulating keyboard events)
- Input Monitoring (for global hotkey)

### Setting up Permissions

1. Open System Preferences > Security & Privacy > Privacy
2. Enable permissions for:
   - Screen Recording
   - Accessibility
   - Input Monitoring
3. Restart the app after granting permissions

## Development Status

This is an MVP (Minimum Viable Product) version that implements the basic functionality of capturing and sharing screenshots. Future versions will include:

- GUI/Status bar menu
- Settings/Preferences
- Custom delays
- Error handling
- Installer
- Auto-updates

## Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please make sure to update tests as appropriate and follow the existing coding style.

## Bug Reports & Feature Requests

If you encounter any bugs or have ideas for new features, please [open an issue](https://github.com/bartwisch/windpix/issues).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the Windsurf team for inspiration and support
- All contributors who help improve this project
