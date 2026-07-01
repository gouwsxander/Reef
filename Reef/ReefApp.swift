//
//  ReefApp.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import Cocoa
import KeyboardShortcuts
import ServiceManagement

@main
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private static var retainedDelegate: AppDelegate?
    static private(set) var instance: AppDelegate!
    static var profileManager: ProfileManager!
    static var sparkleConnector: SparkleConnector!
    static private(set) var modifierManager: ModifierManager!
    
    private var cycleController: CyclePanelController!
    private var shortcutManager: ShortcutController!
    private var windowManager: PreferencesController!
    private var statusItemController: StatusItemController!

    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        retainedDelegate = delegate
        app.run()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self

        AppDelegate.profileManager = ProfileManager()
        AppDelegate.sparkleConnector = SparkleConnector()
        AppDelegate.modifierManager = ModifierManager()

        // Sync launch at login state with system.
        if #available(macOS 13.0, *) {
            UserDefaults.standard.set(SMAppService.mainApp.status == .enabled, forKey: "launchOnLogin")
        }
        
        cycleController = CyclePanelController()
        shortcutManager = ShortcutController(cycleController, AppDelegate.profileManager)
        windowManager = PreferencesController()
        statusItemController = StatusItemController(
            profileManager: AppDelegate.profileManager,
            sparkleConnector: AppDelegate.sparkleConnector,
            modifierManager: AppDelegate.modifierManager
        )

        NSApp.setActivationPolicy(.accessory)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openPreferencesWindow()
        return true
    }

    func application(_ application: NSApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        false
    }

    func application(_ application: NSApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func openPreferencesWindow() {
        guard let windowManager, let profileManager = Self.profileManager, let sparkleConnector = Self.sparkleConnector else {
            return
        }

        windowManager.openSettingsWindow(
            profileManager: profileManager,
            sparkleConnector: sparkleConnector
        )
    }

    func setMenuBarIconHidden(_ hidden: Bool) {
        statusItemController.setHidden(hidden)
    }

    func temporarilyAllowUpdateWindowToFloatAbovePreferences() {
        windowManager.temporarilyAllowUpdateWindowToFloatAboveSettings()
    }

    func applicationWillTerminate(_ notification: Notification) {
        AppDelegate.profileManager?.saveNow()
    }
}
