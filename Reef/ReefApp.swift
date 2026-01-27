//
//  ReefApp.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import SwiftUI
import KeyboardShortcuts

@main
struct ReefApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var bindings = Bindings("Default")

    var body: some Scene {
        Settings {
            PreferencesView()
                .frame(minWidth: 500, minHeight: 200)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 500, height: 200)
        
        MenuBarExtra {
            MenuBarContent(bindings: bindings)
        } label: {
            Image(systemName: "fish.fill")
        }
    }
    
    init() {
        // Initialize AppDelegate with bindings before the app runs
        let bindings = Bindings("Default")
        _bindings = StateObject(wrappedValue: bindings)
        AppDelegate.shared = bindings
    }
}

struct MenuBarContent: View {
    @ObservedObject var bindings: Bindings
    
    var body: some View {
        ForEach(Array(stride(from: 0, through: 9, by: 1)), id: \.self) { i in
            let number = (10 - i) % 10
            if let binding = bindings[number] {
                Button("\(number) | \(binding.title)") {
                    binding.focus()
                }
            }
        }
        
        Divider()
        
        SettingsLink {
            Text("Preferences...")
        }
        
        Button("About Reef") {
            NSApp.orderFrontStandardAboutPanel()
        }
        
        Button("Quit") {
            NSApp.terminate(nil)
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    static var shared: Bindings!
    
    private var cycleController: CyclePanelController!
    private var shortcutManager: ShortcutController!
    private var windowManager: SettingsWindowManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        
        cycleController = CyclePanelController()
        shortcutManager = ShortcutController(cycleController, AppDelegate.shared)
        windowManager = SettingsWindowManager()
        
        NSApp.setActivationPolicy(.accessory)
    }
}

// MARK: - Settings Window Manager

@MainActor
class SettingsWindowManager {
    init() {
        setupWindowObserver()
    }
    
    private func setupWindowObserver() {
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { notification in
            Task { @MainActor in
                guard let window = notification.object as? NSWindow else { return }
                
                if self.isSettingsWindow(window) {
                    self.configureSettingsWindow(window)
                }
            }
        }
    }
    
    private func isSettingsWindow(_ window: NSWindow) -> Bool {
        let windowClass = String(describing: type(of: window))
        return windowClass.contains("AppKitWindow") && window.title == "General"
    }
    
    private func configureSettingsWindow(_ window: NSWindow) {
        // Allow window to appear on all spaces
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Float above other windows
        window.level = .floating
        
        // Bring to front
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}
