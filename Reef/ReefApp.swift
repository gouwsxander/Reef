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
   
    @State private var shortcutManager = ShortcutManager()
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            //Text("Trying something!")
            EmptyView()
        }
    }
    
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    static private(set) var instance: AppDelegate!
    
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu = ApplicationMenu()
    
    var panelController: PanelController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        
        // Create status bar
        statusBarItem.button?.image = NSImage(systemSymbolName: "fish.fill", accessibilityDescription: "Reef menu")
        statusBarItem.button?.imagePosition = .imageLeading
        statusBarItem.menu = menu.createMenu()
        
        statusBarItem.menu?.delegate = self

        panelController = PanelController()

        KeyboardShortcuts.onKeyDown(for: .switcher) { [weak self] in
            self?.panelController.handleSwitcherHotkey()
        }
    }


    @objc func focusWindowFromMenu(sender: NSMenuItem) {
        ConfigManager.config.bindings[sender.tag]?.focus()
    }

    func menuWillOpen(_ menu: NSMenu) {
        menu.removeAllItems()
        print("Test")
        for i in 0...9 {
            let number = (10 - i) % 10
            if let binding = ConfigManager.config.bindings[number] {
                let menuItem = NSMenuItem(
                    title: "\(number) | \(binding.title)",
                    action: #selector(focusWindowFromMenu),
                    keyEquivalent: String(number)
                )
                
                menuItem.tag = number
                menuItem.representedObject = binding
                
                menu.addItem(menuItem)
            }
        }
    }


}
