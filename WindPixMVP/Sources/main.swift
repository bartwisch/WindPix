import Foundation
import Carbon.HIToolbox
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var hotkeyManager: HotkeyManager!
    private var windsurfCheckTimer: Timer?
    private var useFocusChat: Bool = false  // Default to false for existing behavior
    private var autoClose: Bool = true     // Default to true for existing behavior
    private var useAreaSelection: Bool = true  // Default to true for area selection
    
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
            button.image = NSImage(systemSymbolName: "wind", accessibilityDescription: "WindPix")
        }
        
        // Create the menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "WindPix v\(VERSION)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Take Screenshot (⌘P)", action: #selector(takeScreenshot), keyEquivalent: ""))
        
        let areaSelectionItem = NSMenuItem(title: "Use Area Selection", action: #selector(toggleAreaSelection), keyEquivalent: "")
        areaSelectionItem.state = useAreaSelection ? .on : .off
        menu.addItem(areaSelectionItem)
        
        let focusChatItem = NSMenuItem(title: "Focus Chat Before Paste", action: #selector(toggleFocusChat), keyEquivalent: "")
        focusChatItem.state = useFocusChat ? .on : .off
        menu.addItem(focusChatItem)
        
        let autoCloseItem = NSMenuItem(title: "Auto-close with Windsurf", action: #selector(toggleAutoClose), keyEquivalent: "")
        autoCloseItem.state = autoClose ? .on : .off
        menu.addItem(autoCloseItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        // Start periodic check for Windsurf
        windsurfCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            if HotkeyManager.findWindsurfWindow() == nil && self.autoClose {
                print("Windsurf is no longer running and auto-close is enabled. Quitting WindPix...")
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
    
    @objc func toggleAutoClose(_ sender: NSMenuItem) {
        autoClose = !autoClose
        sender.state = autoClose ? .on : .off
    }
    
    @objc func toggleAreaSelection(_ sender: NSMenuItem) {
        useAreaSelection = !useAreaSelection
        sender.state = useAreaSelection ? .on : .off
        hotkeyManager.setUseAreaSelection(useAreaSelection)
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        windsurfCheckTimer?.invalidate()
    }
}

class ScreenshotControlPanel: NSPanel {
    private var acceptAction: () -> Void
    private var redoAction: () -> Void
    private var cancelAction: () -> Void
    private let imageView: NSImageView
    private var retryCount: Int = 0
    private let maxRetries: Int = 5
    
    init(acceptAction: @escaping () -> Void, redoAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        self.acceptAction = acceptAction
        self.redoAction = redoAction
        self.cancelAction = cancelAction
        
        self.imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        
        super.init(contentRect: NSRect(x: 0, y: 0, width: 300, height: 250),
                  styleMask: [.titled, .closable, .nonactivatingPanel],
                  backing: .buffered,
                  defer: false)
        
        self.level = .floating
        self.title = "Screenshot Preview"
        self.isFloatingPanel = true
        self.becomesKeyOnlyIfNeeded = true
        self.backgroundColor = NSColor.windowBackgroundColor
        
        setupUI()
        
        // Position window near the cursor
        if let screenFrame = NSScreen.main?.frame {
            let mouseLocation = NSEvent.mouseLocation
            let x = min(mouseLocation.x, screenFrame.width - frame.width)
            let y = min(mouseLocation.y - frame.height - 10, screenFrame.height - frame.height)
            setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        // Wait for clipboard content
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateWithClipboardContent()
        }
    }
    
    private func setupUI() {
        let contentView = NSView(frame: NSRect(x: 0, y: 0, width: 300, height: 250))
        
        // Setup image view
        imageView.frame = NSRect(x: 10, y: 70, width: 280, height: 170)
        contentView.addSubview(imageView)
        
        // Setup buttons
        let stackView = NSStackView(frame: NSRect(x: 10, y: 10, width: 280, height: 40))
        stackView.orientation = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        
        let acceptButton = NSButton(title: "Accept", target: self, action: #selector(acceptPressed))
        let redoButton = NSButton(title: "Redo", target: self, action: #selector(redoPressed))
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelPressed))
        
        stackView.addArrangedSubview(acceptButton)
        stackView.addArrangedSubview(redoButton)
        stackView.addArrangedSubview(cancelButton)
        
        contentView.addSubview(stackView)
        self.contentView = contentView
    }
    
    private func updateWithClipboardContent() {
        if let clipboard = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
            imageView.image = clipboard
            makeKeyAndOrderFront(nil)
            retryCount = 0
        } else if retryCount < maxRetries {
            retryCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateWithClipboardContent()
            }
        }
    }
    
    @objc private func acceptPressed() {
        close()
        acceptAction()
    }
    
    @objc private func redoPressed() {
        close()
        redoAction()
    }
    
    @objc private func cancelPressed() {
        close()
        cancelAction()
    }
}

class HotkeyManager {
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private var keyMonitor: Any?
    private var mouseMonitor: Any?
    private var controlPanel: ScreenshotControlPanel?
    private var useFocusChat: Bool = true
    private var useAreaSelection: Bool = true
    
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
        removeMouseMonitor()
    }
    
    private func removeMouseMonitor() {
        if let monitor = mouseMonitor {
            NSEvent.removeMonitor(monitor)
            mouseMonitor = nil
        }
    }
    
    private func waitForMouseRelease(completion: @escaping () -> Void) {
        removeMouseMonitor()
        
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseUp, .rightMouseUp]) { [weak self] _ in
            self?.removeMouseMonitor()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion()
            }
        }
    }
    
    private func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        print("Accessibility trusted: \(trusted)")
    }
    
    static func findWindsurfWindow() -> NSRunningApplication? {
        return NSWorkspace.shared.runningApplications.first { app in
            guard let name = app.localizedName else { return false }
            return name == "Windsurf"
        }
    }
    
    func focusWindsurfWindow() throws {
        guard let windsurfApp = HotkeyManager.findWindsurfWindow() else {
            print("Error: Windsurf application not found!")
            throw WindPixError.applicationNotFound
        }
        
        print("Found Windsurf app, attempting to activate...")
        
        // Activate the application
        if !windsurfApp.activate(options: [.activateIgnoringOtherApps]) {
            print("Error: Failed to activate Windsurf window!")
            throw WindPixError.applicationNotFound
        }
        
        print("Successfully activated Windsurf window")
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
    
    func setUseAreaSelection(_ value: Bool) {
        useAreaSelection = value
    }
    
    func automateSequence() {
        print("Starting automation sequence...")
        do {
            let keyCode = useAreaSelection ? CGKeyCode(kVK_ANSI_4) : CGKeyCode(kVK_ANSI_3)
            
            if !useAreaSelection {
                // For full screenshot, focus window immediately and take screenshot
                try focusWindsurfWindow()
                try simulateKeyPress(keyCode: keyCode, flags: [.maskCommand, .maskShift, .maskControl])
                
                // Paste the screenshot after a delay
                pasteScreenshot()
            } else {
                // For area selection, show control panel after screenshot
                try simulateKeyPress(keyCode: keyCode, flags: [.maskCommand, .maskShift, .maskControl])
                
                // Wait a bit before showing the control panel
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    guard let self = self else { return }
                    
                    self.controlPanel = ScreenshotControlPanel(
                        acceptAction: { [weak self] in
                            // Accept: Focus Windsurf window and paste
                            do {
                                try self?.focusWindsurfWindow()
                                self?.pasteScreenshot()
                            } catch {
                                print("Error focusing window: \(error)")
                            }
                        },
                        redoAction: { [weak self] in
                            // Redo: Start new area selection
                            self?.automateSequence()
                        },
                        cancelAction: {
                            // Cancel: Do nothing, panel is already closed
                            print("Screenshot cancelled")
                        }
                    )
                    
                    self.controlPanel?.makeKeyAndOrderFront(nil)
                }
            }
        } catch {
            print("Error in automation sequence: \(error)")
        }
    }
    
    func pasteScreenshot() {
        do {
            // Wait a bit to ensure window is focused
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                do {
                    // Paste (Command + V)
                    try self?.simulateKeyPress(keyCode: CGKeyCode(kVK_ANSI_V), flags: .maskCommand)
                } catch {
                    print("Error pasting screenshot: \(error)")
                }
            }
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
