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
                // Simulate Command + L to focus Windsurf chat
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
                print("Error simulating chat focus: \(error)")
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
        
        // Register the hotkey (Command + Shift + 4)
        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_ANSI_4),
            UInt32(cmdKey | shiftKey),
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
    try hotkeyManager.register()
    print("Hotkey registered (Command + Shift + 4)")
    print("Press Ctrl+C to exit")
    
    // Keep the program running
    RunLoop.main.run()
} catch {
    print("Error: \(error)")
    exit(1)
}
