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

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    
    lazy var statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let menu = ApplicationMenu()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        
        // Create status bar
        statusBarItem.button?.image = NSImage(systemSymbolName: "fish.fill", accessibilityDescription: "Reef menu")
        statusBarItem.button?.imagePosition = .imageLeading
        statusBarItem.menu = menu.createMenu()
    }
    
    
    @objc func focusWindowFromMenu(sender: NSMenuItem) {
        config.bindings[sender.tag]?.focus()
    }
    
    func updateMenu() {
        // Obviously inefficient, but it shouldn't actually matter
        menu.menu.removeAllItems()
        
        for i in 0...9 {
            let number = (10 - i) % 10
            if let focusElement = config.bindings[number] {
                let menuItem = NSMenuItem(
                    title: "\(number) | \(focusElement.title)",
                    action: #selector(focusWindowFromMenu),
                    keyEquivalent: String(number)
                )
                
                // Terribly illedgible
                // menuItem.image = NSImage(systemSymbolName: "\(number).square.fill", accessibilityDescription: "Number \(number)")

                menuItem.tag = number // maybe use .target?
                
                menu.menu.addItem(menuItem)
            }
        }
    }
    
}


