# WindPix - Screenshot Integration for Windsurf

## Overview
WindPix is a macOS utility that streamlines the process of sharing screenshots within the Windsurf application. It automates the workflow of capturing, copying, and sending screenshots to the LLM chat interface.

## Core Functionality
1. **Screenshot Capture**
   - Triggered by a custom keyboard shortcut
   - Automatically copies screenshot to clipboard

2. **Windsurf Integration**
   - Automatically focuses Windsurf chat window (`cmd + shift + l`)
   - Pastes screenshot from clipboard (`cmd + v`)
   - Submits the image to LLM (Enter key)

## Technical Implementation
1. **Screenshot Mechanism**
   - Utilize macOS native screenshot API
   - Implement clipboard management

2. **Automation Flow**
   - Keyboard shortcut: `cmd + shift + l`
   - Automatically focuses Windsurf window
   - Handles screenshot pasting and submission

## User Experience
- Single keyboard shortcut initiates entire workflow
- Minimal user intervention required
- Configurable delays between actions

## Future Enhancements
- Configurable keyboard shortcuts![
   
](image.png)
- Custom screenshot area selection
- Success/failure notifications
- Preview before sending
