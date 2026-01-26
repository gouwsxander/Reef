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
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    static private(set) var instance: AppDelegate!
    
    private var bindings: Bindings!
    private var menuController: MenuController!
    private var cycleController: CyclePanelController!
    @State private var shortcutManager: ShortcutController!
    
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        
        bindings = Bindings("Default")
        menuController = MenuController(bindings)
        cycleController = CyclePanelController()
        shortcutManager = ShortcutController(cycleController, bindings)
        
        // Create status bar
        statusBarItem.button?.image = NSImage(systemSymbolName: "fish.fill", accessibilityDescription: "Reef menu")
        statusBarItem.button?.imagePosition = .imageLeading
        
        statusBarItem.menu = menuController.menu
        statusBarItem.menu?.delegate = self
    }

    func menuWillOpen(_ menu: NSMenu) {
        self.menuController.updateMenu()
    }
}
