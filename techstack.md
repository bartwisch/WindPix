# WindPix Technical Stack

## Core Technologies

### Programming Language
- **Swift 5.9+**
  - Native macOS development
  - Direct access to macOS APIs
  - Excellent performance
  - Small binary size

### Frameworks
- **AppKit**
  - Native macOS UI components
  - System tray integration
  - Window management
  - Clipboard operations

- **Foundation**
  - Core system functionality
  - File operations
  - Event handling

### System Integration
- **NSScreen**
  - Screen capture functionality
  - Multi-monitor support

- **Global Shortcuts**
  - Carbon Hot Key API
  - System-wide keyboard shortcut registration

- **Accessibility API**
  - Window focus management
  - Keyboard event simulation

### Development Tools
- **Xcode 15+**
  - IDE and development environment
  - Interface Builder
  - Debugging tools
  - Performance profiling

- **SwiftLint**
  - Code style enforcement
  - Best practices checking

### Build & Distribution
- **App Notarization**
  - Code signing
  - macOS security compliance

- **Sparkle**
  - Optional: Future auto-update support

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
