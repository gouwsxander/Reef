//
//  PreferencesController.swift
//  Reef
//
//  Created by Xander Gouws on 28-01-2026.
//

import SwiftUI

@MainActor
class PreferencesController {
    static let settingsWindowIdentifier = NSUserInterfaceItemIdentifier("Reef.SettingsWindow")
    
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
        Self.isLikelySettingsWindow(window)
    }
    
    private func configureSettingsWindow(_ window: NSWindow) {
        // Keep settings on the current Space and move it to the active one when reopened.
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        
        // Keep standard window ordering; only force focus when opening settings.
        window.level = .floating
        window.identifier = Self.settingsWindowIdentifier
        
        // Bring to front
        NSApp.activate(ignoringOtherApps: true)
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)
    }
    
    static func isLikelySettingsWindow(_ window: NSWindow) -> Bool {
        if window.identifier == settingsWindowIdentifier {
            return true
        }
        
        let windowClass = String(describing: type(of: window))
        return windowClass.contains("AppKitWindow")
    }
}
