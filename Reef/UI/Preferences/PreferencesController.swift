//
//  PreferencesController.swift
//  Reef
//
//  Created by Xander Gouws on 28-01-2026.
//

import SwiftUI

@MainActor
class PreferencesController {
    init() {
        setupWindowObserver()
    }
    
    private func setupWindowObserver() {
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { notification in
            Task { @MainActor in
                guard let window = notification.object as? NSWindow else { return }
                
                if self.isSettingsWindow(window) {
                    self.configureSettingsWindow(window)
                }
            }
        }
    }
    
    private func isSettingsWindow(_ window: NSWindow) -> Bool {
        let windowClass = String(describing: type(of: window))
        return windowClass.contains("AppKitWindow") && window.title == "General"
    }
    
    private func configureSettingsWindow(_ window: NSWindow) {
        // Allow window to appear on all spaces
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Float above other windows
        window.level = .floating
        
        // Bring to front
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }
}
