//
//  ReefApp.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import SwiftUI
import KeyboardShortcuts
import SwiftData

@main
struct ReefApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var profileManager: ProfileManager
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Bindings.self)
            let profileManager = ProfileManager(modelContext: modelContainer.mainContext)
            _profileManager = StateObject(wrappedValue: profileManager)
            AppDelegate.profileManager = profileManager
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        Settings {
            PreferencesView()
                .modelContainer(modelContainer)
                .environmentObject(profileManager)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarView()
                .modelContainer(modelContainer)
                .environmentObject(profileManager)
        } label: {
            Image(systemName: "fish.fill")
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
}
