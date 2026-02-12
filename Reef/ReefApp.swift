//
//  ReefApp.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import SwiftUI
import KeyboardShortcuts
import ServiceManagement

@main
struct ReefApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var profileManager: ProfileManager
    @AppStorage("launchOnLogin") private var launchOnLogin = true
    
    init() {
        let profileManager = ProfileManager()
        _profileManager = StateObject(wrappedValue: profileManager)
        AppDelegate.profileManager = profileManager
        
        // Sync launch at login state with system
        if #available(macOS 13.0, *) {
            let status = SMAppService.mainApp.status
            _launchOnLogin = AppStorage(wrappedValue: status == .enabled, "launchOnLogin")
        }
    }

    var body: some Scene {
        Settings {
            PreferencesView()
                .environmentObject(profileManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarView()
                .environmentObject(profileManager)
        } label: {
            Image("menu_placeholder")
            // Image(systemName: "fish.fill")
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    static var profileManager: ProfileManager!
    static private(set) var modifierManager: ModifierManager!
    
    private var cycleController: CyclePanelController!
    private var shortcutManager: ShortcutController!
    private var windowManager: PreferencesController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        AppDelegate.modifierManager = ModifierManager()
        
        cycleController = CyclePanelController()
        shortcutManager = ShortcutController(cycleController, AppDelegate.profileManager)
        windowManager = PreferencesController()
        
        NSApp.setActivationPolicy(.accessory)
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppDelegate.profileManager.saveNow()
    }
}
