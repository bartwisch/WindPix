# WindPix Technical Stack

## Core Technologies

### Programming Language
- **Swift 5.9+**
  - Native macOS development
  - System API integration
  - Clean and modern syntax
  - Type-safe operations

### Frameworks Used
- **AppKit**
  - System tray implementation
  - Window and panel management
  - Menu creation and handling
  - Basic UI components

- **Foundation**
  - Core functionality
  - File operations
  - Timer management
  - Error handling

- **Carbon**
  - Global hotkey registration
  - Keyboard event handling

### System Integration
- **Screenshot Capabilities**
  - Native screenshot commands
  - Area selection support
  - Clipboard management

- **Window Management**
  - Windsurf window detection
  - Focus management
  - Event simulation

### Development Tools
- **Xcode**
  - Development environment
  - Debugging tools
  - Performance monitoring

### Distribution
- **GitHub**
  - Version control
  - Issue tracking
  - Release management

### Current Architecture
- **AppDelegate**
  - Application lifecycle
  - Menu management
  - Configuration handling

- **HotkeyManager**
  - Keyboard event handling
  - Screenshot automation
  - Window management

- **ScreenshotControlPanel**
  - User interface for preview
  - Action handling
  - Visual feedback

## System Requirements
- macOS 13.0 (Ventura) or newer
- 20MB disk space
- Minimal RAM usage

## Development Environment Setup
1. Install Xcode from Mac App Store
2. Install command line tools:
   ```bash
   xcode-select --install
   ```
3. Clone repository and open in Xcode

## Testing Framework
- **XCTest**
  - Unit testing
  - UI testing
  - Performance testing
