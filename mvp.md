# WindPix MVP Plan

## Core Features
1. Global hotkey to trigger screenshot (⌘⇧4)
2. 1-second delay after screenshot
3. Simulate ⌘L to focus Windsurf chat
4. 1-second delay
5. Simulate ⌘V to paste screenshot
6. 1-second delay
7. Simulate Enter to send

## MVP Tech Stack
- Swift command-line tool (no GUI needed yet)
- Global hotkey registration using Carbon API
- Basic keyboard event simulation using CGEvent

## MVP Implementation Steps

1. **Basic Command Line Tool**
```swift
// main.swift
import Foundation
import Carbon
import CoreGraphics

// Register hotkey and handle events
```

2. **Required Permissions**
- Screen Recording
- Accessibility
- Input Monitoring

## Testing MVP
1. Launch app from terminal
2. Press hotkey
3. Verify automation sequence works with Windsurf

## Success Criteria
- Can take screenshot with hotkey
- Screenshot is automatically pasted into Windsurf
- Message is automatically sent
- Entire sequence works reliably

## What's NOT in MVP
- GUI/Status bar
- Settings/Preferences
- Custom delays
- Error handling
- Installer
- Auto-updates
- Multiple monitor support
- Custom screenshot area
