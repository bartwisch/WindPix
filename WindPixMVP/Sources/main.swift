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
        // Start checking for Windsurf
        windsurfCheckTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            if HotkeyManager.findWindsurfWindow() != nil {
                // Windsurf is running, stop the timer and initialize the app
                timer.invalidate()
                self?.initializeApp()
            } else {
                print("Waiting for Windsurf to start...")
            }
        }
    }
    
    private func initializeApp() {
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "wind", accessibilityDescription: "WindPix")
        }
        
        // Create the menu
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "WindPix v\(VERSION)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "How To", action: #selector(showInstructions), keyEquivalent: "h"))
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
    
    @objc func showInstructions() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 700, height: 600),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "WindPix Instructions"
        window.center()
        window.backgroundColor = .windowBackgroundColor
        
        let containerView = NSView(frame: window.contentView!.bounds)
        containerView.autoresizingMask = [.width, .height]
        
        // Create title label
        let titleLabel = NSTextField(labelWithString: "WindPix Instructions")
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .labelColor
        titleLabel.frame = NSRect(x: 20, y: containerView.frame.height - 60, width: containerView.frame.width - 40, height: 30)
        titleLabel.alignment = .center
        titleLabel.autoresizingMask = [.width]
        
        // Create scroll view for content
        let scrollView = NSScrollView(frame: NSRect(x: 20, 
                                                   y: 100, 
                                                   width: containerView.frame.width - 40, 
                                                   height: containerView.frame.height - 180))
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = [.width, .height]
        scrollView.borderType = .noBorder
        
        let contentView = NSTextView(frame: scrollView.bounds)
        contentView.isEditable = false
        contentView.autoresizingMask = [.width]
        contentView.textContainerInset = NSSize(width: 20, height: 20)
        contentView.backgroundColor = .clear
        
        if let instructionsPath = "/Users/christophwurzer/Development/windpix/instructions.md" as String?,
           let instructions = try? String(contentsOfFile: instructionsPath, encoding: .utf8) {
            let attributedString = NSMutableAttributedString()
            
            // Style the content
            let paragraphs = instructions.components(separatedBy: "\n\n")
            for (index, paragraph) in paragraphs.enumerated() {
                if index > 0 {
                    attributedString.append(NSAttributedString(string: "\n\n"))
                }
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 8
                
                if paragraph.hasPrefix("example:") {
                    // Style the example section header
                    attributedString.append(NSAttributedString(
                        string: "Example:\n",
                        attributes: [
                            .font: NSFont.boldSystemFont(ofSize: 16),
                            .foregroundColor: NSColor.labelColor,
                            .paragraphStyle: paragraphStyle
                        ]
                    ))
                    // Add the example content
                    let steps = paragraph.replacingOccurrences(of: "example:\n", with: "")
                    attributedString.append(NSAttributedString(
                        string: steps,
                        attributes: [
                            .font: NSFont.systemFont(ofSize: 14),
                            .foregroundColor: NSColor.labelColor,
                            .paragraphStyle: paragraphStyle
                        ]
                    ))
                } else if paragraph.hasPrefix("Notes:") {
                    // Style the notes section
                    attributedString.append(NSAttributedString(
                        string: "Notes:\n",
                        attributes: [
                            .font: NSFont.boldSystemFont(ofSize: 16),
                            .foregroundColor: NSColor.labelColor,
                            .paragraphStyle: paragraphStyle
                        ]
                    ))
                    // Add the notes content
                    let notes = paragraph.replacingOccurrences(of: "Notes:\n", with: "")
                    attributedString.append(NSAttributedString(
                        string: notes,
                        attributes: [
                            .font: NSFont.systemFont(ofSize: 14),
                            .foregroundColor: NSColor.labelColor,
                            .paragraphStyle: paragraphStyle
                        ]
                    ))
                } else {
                    // Style regular paragraphs
                    attributedString.append(NSAttributedString(
                        string: paragraph,
                        attributes: [
                            .font: NSFont.systemFont(ofSize: 14),
                            .foregroundColor: NSColor.labelColor,
                            .paragraphStyle: paragraphStyle
                        ]
                    ))
                }
            }
            
            contentView.textStorage?.setAttributedString(attributedString)
        } else {
            contentView.string = "Instructions could not be loaded."
        }
        
        scrollView.documentView = contentView
        
        // Create footer with contact info
        let footerLabel = NSTextField(labelWithString: "Created by Hugo (bartwisch666@gmail.com)")
        footerLabel.font = .systemFont(ofSize: 12)
        footerLabel.textColor = .secondaryLabelColor
        footerLabel.frame = NSRect(x: 20, y: 20, width: containerView.frame.width - 40, height: 20)
        footerLabel.alignment = .center
        footerLabel.autoresizingMask = [.width]
        
        // Add all views to container
        containerView.addSubview(titleLabel)
        containerView.addSubview(scrollView)
        containerView.addSubview(footerLabel)
        
        window.contentView = containerView
        
        let controller = NSWindowController(window: window)
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
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
    private var updateTimer: Timer?
    private var lastChangeCount: Int
    
    init(acceptAction: @escaping () -> Void, redoAction: @escaping () -> Void, cancelAction: @escaping () -> Void) {
        self.acceptAction = acceptAction
        self.redoAction = redoAction
        self.cancelAction = cancelAction
        
        self.imageView = NSImageView()
        imageView.imageScaling = .scaleProportionallyUpOrDown
        self.lastChangeCount = NSPasteboard.general.changeCount
        
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
        setupClipboardMonitoring()
        
        // Position window near the cursor
        if let screenFrame = NSScreen.main?.frame {
            let mouseLocation = NSEvent.mouseLocation
            let x = min(mouseLocation.x, screenFrame.width - frame.width)
            let y = min(mouseLocation.y - frame.height - 10, screenFrame.height - frame.height)
            setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        makeKeyAndOrderFront(nil)
    }
    
    deinit {
        updateTimer?.invalidate()
    }
    
    private func setupClipboardMonitoring() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkClipboardChanges()
        }
    }
    
    private func checkClipboardChanges() {
        let currentCount = NSPasteboard.general.changeCount
        if currentCount != lastChangeCount {
            lastChangeCount = currentCount
            updateWithClipboardContent()
        }
    }
    
    private func updateWithClipboardContent() {
        if let clipboard = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage {
            imageView.image = clipboard
            retryCount = 0
        } else if retryCount < maxRetries {
            retryCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateWithClipboardContent()
            }
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
    @objc var useAreaSelection: Bool = true {
        didSet {
            if !useAreaSelection {
                // Close preview window when area selection is disabled
                controlPanel?.close()
                controlPanel = nil
            }
            updateMenuItems()
        }
    }
    
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
                // Close preview window if it exists
                controlPanel?.close()
                controlPanel = nil
                
                print("Taking full screenshot with Cmd+Shift+Control+3...")
                // Take screenshot first
                try simulateKeyPress(keyCode: keyCode, flags: [.maskCommand, .maskShift, .maskControl])
                
                // Wait for clipboard to update
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    do {
                        print("Focusing Windsurf window...")
                        // Then focus window and paste
                        try self?.focusWindsurfWindow()
                        
                        print("Attempting to paste screenshot...")
                        self?.pasteScreenshot()
                    } catch {
                        print("Error focusing window: \(error)")
                    }
                }
            } else {
                // For area selection: Show control panel and wait for user action
                try simulateKeyPress(keyCode: keyCode, flags: [.maskCommand, .maskShift, .maskControl])
                
                // Create control panel after screenshot command
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
    
    private func updateMenuItems() {
        // Update menu items
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
