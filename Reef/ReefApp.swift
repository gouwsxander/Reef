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
}


