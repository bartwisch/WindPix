# Hooman
hi! this text and the content of "markups/idea.md" is the only text or code you will find in this repo that is not AI. i know its kinda creepy, but i really try to play around with what is currently possible with AI. i first created a mac only app in swift but then asked ai to switch to multiplatform and here we are. yours, hugo bartwisch 

# WindPix

A modern Electron-based screenshot utility for Windows, macOS, and Linux. Built with Node.js, it provides an efficient and user-friendly interface for taking screenshots and feed them into Windsurf.

![WindPix Logo](windpix-electron/assets/512.png)

## How to use
1. open WindPix and Windsurf
2. Press ⌘P (macOS) or Ctrl+P (Windows/Linux) to start a capture
3. Click and drag to select an area
4. After taking a screenshot, WindPix will automatically focus on Windsurf
5. You can press cmd+v or ctrl+v to paste the screenshot into the chat

## Features

- 📸 Modern image viewer interface
- 🚀 Cross-platform support (macOS, Windows, Linux)
- 💻 Built with Electron and Node.js
- 🎯 Windsurf autofocus
- Toogle between area select mode and full screen mode

## Installation

Download the latest release for your platform:
- macOS: `.dmg` installer
- Windows: `.exe` installer
- Linux: [WindPix-1.0.0-arm64.AppImage](windpix/windpix-electron/dist/WindPix-1.0.0-arm64.AppImage) installer

## Development

### Prerequisites
- Node.js (v16 or higher)
- npm

### Setup
```bash
# Clone the repository
git clone https://github.com/bartwisch/windpix.git

# Navigate to electron app directory
cd windpix/windpix-electron

# Install dependencies
npm install

# Start the development server
npm start
```

### Building
```bash
# Build for your current platform
npm run build
```

## License

ISC License

## Tags
- electron-app
- screenshot-utility
- windsurf
