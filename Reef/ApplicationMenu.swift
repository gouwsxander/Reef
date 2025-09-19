//
//  ApplicationMenu.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import Foundation
import SwiftUI

class ApplicationMenu: NSObject {
    let menu = NSMenu()
    
    func createMenu() -> NSMenu {
        menu.addItem(NSMenuItem())
        
        menu.addItem(NSMenuItem.separator())
        
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
            keyEquivalent: "q"
        )
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
        
        return menu
    }
    
    @objc func about(sender: NSMenuItem) {
        NSApp.orderFrontStandardAboutPanel()
    }
    
    @objc func quit(sender: NSMenuItem) {
        NSApp.terminate(self)
    }
}
