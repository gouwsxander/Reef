//
//  MenuController.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import Foundation
import SwiftUI


@MainActor
final class MenuController {
    let menu = NSMenu()
    var bindings: Bindings
    
    init(_ bindings: Bindings) {
        self.bindings = bindings
    }

    func updateMenu() {
        menu.removeAllItems()
        for i in 0...9 {
            let number = (10 - i) % 10
            if let binding = bindings[number] {
                let menuItem = NSMenuItem(
                    title: "\(number) | \(binding.title)",
                    action: #selector(focusAppFromMenu),
                    keyEquivalent: ""
                )
                
                menuItem.tag = number
                menuItem.representedObject = binding
                menuItem.target = self
                
                menu.addItem(menuItem)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let preferencesMenuItem = NSMenuItem(
                title: "Preferences...",
                action: #selector(openPreferences),
                keyEquivalent: ""
            )
        preferencesMenuItem.target = self
        menu.addItem(preferencesMenuItem)
        
        let aboutMenuItem = NSMenuItem(
            title: "About Reef",
            action: #selector(about),
            keyEquivalent: ""
        )
        aboutMenuItem.target = self
        menu.addItem(aboutMenuItem)
        
        let quitMenuItem = NSMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: ""
        )
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
    }
    
    @objc func focusAppFromMenu(sender: NSMenuItem) {
        bindings[sender.tag]?.focus()
    }
    
    @objc func openPreferences(sender: NSMenuItem) {
        // TODO
    }

    @objc func about(sender: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel()
    }
    
    @objc func quit(sender: NSMenuItem) {
        NSApp.terminate(nil)
    }
}
