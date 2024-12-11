import Foundation
import Carbon.HIToolbox
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var hotkeyManager: HotkeyManager!
    private var windsurfCheckTimer: Timer?
    private var useFocusChat: Bool = true  // Default to true for existing behavior
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check if Windsurf is running
        guard HotkeyManager.findWindsurfWindow() != nil else {
            print("Windsurf is not running. Quitting WindPix...")
            NSApplication.shared.terminate(nil)
            return
        }
        
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "camera", accessibilityDescription: "WindPix")
        }
        
        // Create the menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "WindPix v\(VERSION)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Take Screenshot (⌘P)", action: #selector(takeScreenshot), keyEquivalent: ""))
        
        let focusChatItem = NSMenuItem(title: "Focus Chat Before Paste", action: #selector(toggleFocusChat), keyEquivalent: "")
        focusChatItem.state = useFocusChat ? .on : .off
        menu.addItem(focusChatItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        // Start periodic check for Windsurf
        windsurfCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if HotkeyManager.findWindsurfWindow() == nil {
                print("Windsurf is no longer running. Quitting WindPix...")
                NSApplication.shared.terminate(nil)
            }
        }
        
        // Initialize hotkey manager
        hotkeyManager = HotkeyManager()
        do {
            try hotkeyManager.register()
            print("Hotkey registered (Command + P)")
        } catch {
            print("Failed to register hotkey: \(error)")
        }
    }
    
    @objc func takeScreenshot() {
        hotkeyManager.automateSequence()
    }
    
    @objc func toggleFocusChat(_ sender: NSMenuItem) {
        useFocusChat = !useFocusChat
        sender.state = useFocusChat ? .on : .off
        hotkeyManager.setUseFocusChat(useFocusChat)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        windsurfCheckTimer?.invalidate()
    }
}

class HotkeyManager {
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private var keyMonitor: Any?
    private var useFocusChat: Bool = true  // Default to true for existing behavior
    
    deinit {
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    private func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        print("Accessibility trusted: \(trusted)")
    }
    
    static func findWindsurfWindow() -> NSRunningApplication? {
        let apps = NSWorkspace.shared.runningApplications
        return apps.first { app in
            guard let name = app.localizedName?.lowercased() else { return false }
            return name == "windsurf"
        }
    }
    
    func focusWindsurfWindow() throws {
        guard let windsurfApp = HotkeyManager.findWindsurfWindow() else {
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
        print("Simulating key press with keyCode: \(keyCode), flags: \(flags)")
        guard let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: true) else {
            print("Failed to create keyDown event")
            throw WindPixError.simulationFailed
        }
        keyDownEvent.flags = flags
        keyDownEvent.post(tap: .cghidEventTap)
        
        guard let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: false) else {
            print("Failed to create keyUp event")
            throw WindPixError.simulationFailed
        }
        keyUpEvent.flags = flags
        keyUpEvent.post(tap: .cghidEventTap)
    }
    
    func setUseFocusChat(_ value: Bool) {
        useFocusChat = value
    }
    
    func automateSequence() {
        print("Starting automation sequence...")
        do {
            print("Taking screenshot (Command + Shift + Control + 3)...")
            // First simulate Command + Shift + Control + 3 to copy screenshot to clipboard
            try simulateKeyPress(keyCode: CGKeyCode(kVK_ANSI_3), flags: [.maskCommand, .maskShift, .maskControl])
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                do {
                    print("Focusing Windsurf window...")
                    // Then focus the Windsurf window
                    try self.focusWindsurfWindow()
                    
                    if self.useFocusChat {
                        print("Focusing chat (Command + Shift + L)...")
                        // Then simulate Command + Shift + L to focus chat
                        try self.simulateKeyPress(keyCode: 0x25, flags: [.maskCommand, .maskShift]) // 'L' key
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            do {
                                print("Pasting screenshot (Command + V)...")
                                // Simulate Command + V to paste
                                try self.simulateKeyPress(keyCode: 0x09, flags: .maskCommand) // 'V' key
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    do {
                                        print("Sending message (Return)...")
                                        // Simulate Return to send
                                        try self.simulateKeyPress(keyCode: 0x24, flags: []) // Return key
                                    } catch {
                                        print("Error sending message: \(error)")
                                    }
                                }
                            } catch {
                                print("Error pasting screenshot: \(error)")
                            }
                        }
                    } else {
                        // If not using focus chat, directly paste the screenshot
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            do {
                                print("Pasting screenshot (Command + V)...")
                                try self.simulateKeyPress(keyCode: 0x09, flags: .maskCommand) // 'V' key
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    do {
                                        print("Sending message (Return)...")
                                        try self.simulateKeyPress(keyCode: 0x24, flags: []) // Return key
                                    } catch {
                                        print("Error sending message: \(error)")
                                    }
                                }
                            } catch {
                                print("Error pasting screenshot: \(error)")
                            }
                        }
                    }
                } catch {
                    print("Error focusing Windsurf window: \(error)")
                }
            }
        } catch {
            print("Error taking screenshot: \(error)")
        }
    }
    
    func register() throws {
        print("Starting hotkey registration...")
        
        // Request accessibility permissions
        requestAccessibility()
        
        // Monitor all key events using local monitor (works better than global)
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { event in
            let flags = event.modifierFlags
            var modifierStr = ""
            
            if flags.contains(.command) { modifierStr += "⌘ " }
            if flags.contains(.option) { modifierStr += "⌥ " }
            if flags.contains(.shift) { modifierStr += "⇧ " }
            if flags.contains(.control) { modifierStr += "⌃ " }
            
            if event.type == .keyDown {
                let keyChar = event.charactersIgnoringModifiers ?? ""
                print("Key pressed: \(modifierStr)\(keyChar) (keyCode: \(event.keyCode))")
                
                // Check for Command + P
                if flags.contains(.command) && event.keyCode == kVK_ANSI_P {
                    print("Command + P detected! Taking screenshot...")
                    self.automateSequence()
                }
            } else if event.type == .flagsChanged {
                print("Modifiers changed: \(modifierStr)")
            }
            
            return event
        }
        
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )
        
        print("Setting up event handler...")
        // Store self in the global reference
        activeManager = self
        
        // Install event handler
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, _, _) -> OSStatus in
                print("\n🔥 Hotkey triggered! (Command + P)")
                activeManager?.automateSequence()
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )
        
        if status != noErr {
            print("❌ Failed to install event handler with status: \(status)")
            throw WindPixError.hotkeyRegistrationFailed
        }
        print("✅ Event handler installed successfully")
        
        // Register the hotkey (Command + P)
        print("Registering hotkey Command + P...")
        let registerStatus = RegisterEventHotKey(
            UInt32(kVK_ANSI_P),  // P key
            UInt32(cmdKey),  // Just Command key for testing
            EventHotKeyID(signature: OSType(0x57504958), // "WPIX"
                         id: 1),
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if registerStatus != noErr {
            print("❌ Failed to register hotkey with status: \(registerStatus)")
            throw WindPixError.hotkeyRegistrationFailed
        }
        print("✅ Hotkey registered successfully")
        print("🚀 WindPix is ready! Press Command + P to test...")
    }
}

// Error type for handling various errors
enum WindPixError: Error {
    case hotkeyRegistrationFailed
    case simulationFailed
    case screenshotFailed
    case applicationNotFound
}

var activeManager: HotkeyManager?

// Version
let VERSION = "0.1.0"

// Create and run the application
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
