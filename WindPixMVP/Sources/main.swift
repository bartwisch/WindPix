import Foundation
import Carbon
import CoreGraphics
import AppKit

// Link Carbon framework
#if canImport(Carbon)
import Carbon.HIToolbox
#endif

// Error type for handling various errors
enum WindPixError: Error {
    case hotkeyRegistrationFailed
    case simulationFailed
    case screenshotFailed
    case applicationNotFound
}

// Global reference to the active HotkeyManager instance
var activeManager: HotkeyManager?

class HotkeyManager {
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    
    deinit {
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
    }
    
    func listWindows() {
        print("\nListing all windows:")
        let options = CGWindowListOption([.optionOnScreenOnly, .excludeDesktopElements])
        let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []
        
        for window in windowList {
            let ownerName = window[kCGWindowOwnerName as String] as? String ?? "Unknown"
            let windowName = window[kCGWindowName as String] as? String ?? ""
            let windowLayer = window[kCGWindowLayer as String] as? Int ?? 0
            
            // Only show windows that are likely to be application windows
            if windowLayer == 0 {
                print("- \(ownerName) (\(windowName))")
            }
        }
    }
    
    func findWindsurfWindow() -> NSRunningApplication? {
        let apps = NSWorkspace.shared.runningApplications
        print("\nRunning applications:")
        for app in apps {
            if let name = app.localizedName {
                print("- \(name)")
            }
        }
        
        // List all windows to help identify the correct application
        listWindows()
        
        // Try different possible names
        let possibleNames = ["Windsurf", "WindSurf", "windsurf", "Windsurf IDE", "WindsurfIDE"]
        return apps.first { app in
            guard let name = app.localizedName else { return false }
            return possibleNames.contains(name)
        }
    }
    
    func focusWindsurfWindow() throws {
        guard let windsurfApp = findWindsurfWindow() else {
            print("Error: Windsurf application not found!")
            throw WindPixError.applicationNotFound
        }
        
        // Activate the application
        if !windsurfApp.activate(options: .activateIgnoringOtherApps) {
            print("Error: Failed to activate Windsurf window!")
            throw WindPixError.applicationNotFound
        }
    }
    
    func simulateKeyPress(keyCode: CGKeyCode, flags: CGEventFlags) throws {
        guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else {
            throw WindPixError.simulationFailed
        }
        keyDownEvent.flags = flags
        keyDownEvent.post(tap: .cghidEventTap)
        
        guard let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else {
            throw WindPixError.simulationFailed
        }
        keyUpEvent.flags = flags
        keyUpEvent.post(tap: .cghidEventTap)
    }
    
    func automateSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            do {
                // First, focus the Windsurf window
                try self.focusWindsurfWindow()
                
                // Then simulate Command + L to focus chat
                try self.simulateKeyPress(keyCode: 0x25, flags: .maskCommand) // 'L' key
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    do {
                        // Simulate Command + V to paste
                        try self.simulateKeyPress(keyCode: 0x09, flags: .maskCommand) // 'V' key
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            do {
                                // Simulate Return to send
                                try self.simulateKeyPress(keyCode: 0x24, flags: []) // Return key
                            } catch {
                                print("Error simulating Return key: \(error)")
                            }
                        }
                    } catch {
                        print("Error simulating paste: \(error)")
                    }
                }
            } catch {
                print("Error focusing Windsurf window: \(error)")
            }
        }
    }
    
    func register() throws {
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )
        
        // Store self in the global reference
        activeManager = self
        
        // Install event handler
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, _, _) -> OSStatus in
                print("Hotkey pressed!")
                activeManager?.automateSequence()
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )
        
        if status != noErr {
            throw WindPixError.hotkeyRegistrationFailed
        }
        
        // Register the hotkey (Command + Option + P)
        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_ANSI_P),  // P key
            UInt32(cmdKey | optionKey),  // Command + Option
            EventHotKeyID(signature: OSType(0x57504958), // "WPIX"
                         id: 1),
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if registerStatus != noErr {
            throw WindPixError.hotkeyRegistrationFailed
        }
    }
}

// Main execution
print("Starting WindPix MVP...")

let hotkeyManager = HotkeyManager()
do {
    // Print running applications and windows at startup
    print("\nListing all running applications and windows to help identify Windsurf...")
    _ = hotkeyManager.findWindsurfWindow()
    
    try hotkeyManager.register()
    print("\nHotkey registered (Command + Option + P)")
    print("Press Ctrl+C to exit")
    
    // Keep the program running
    RunLoop.main.run()
} catch {
    print("Error: \(error)")
    exit(1)
}
