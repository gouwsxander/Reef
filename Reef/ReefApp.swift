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
                .frame(minWidth: 100)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarView(bindings: bindings)
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


@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    static var shared: Bindings!
    static private(set) var modifierManager: ModifierManager!
    
    private var cycleController: CyclePanelController!
    private var shortcutManager: ShortcutController!
    private var windowManager: PreferencesController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        
        AppDelegate.modifierManager = ModifierManager()
        
        cycleController = CyclePanelController()
        shortcutManager = ShortcutController(cycleController, AppDelegate.shared)
        windowManager = PreferencesController()
        
        NSApp.setActivationPolicy(.accessory)
    }
}
