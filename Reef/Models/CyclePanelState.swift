//
//  CyclePanelState.swift
//  Reef
//
//  Created by Xander Gouws on 23-01-2026.
//

import Foundation
import ApplicationServices

enum CyclePanelAction {
    case launchApp
    case openWindow
    case requestAccessibility

    var title: String {
        switch self {
        case .launchApp:
            return "Launch app"
        case .openWindow:
            return "Focus app"
        case .requestAccessibility:
            return "Enable Accessibility Access…"
        }
    }
}

enum CyclePanelItem {
    case window(Window)
    case action(CyclePanelAction)
}

@MainActor
final class CyclePanelState: ObservableObject {
    @Published var applicationTitle: String = ""
    @Published var items: [CyclePanelItem] = []
    @Published var selectedIndex: Int = 0
    
    var windows: [Window] {
        items.compactMap { item in
            if case let .window(window) = item {
                return window
            }
            
            return nil
        }
    }
    
    var currentItem: CyclePanelItem? {
        guard !items.isEmpty, selectedIndex < items.count else { return nil }
        return items[selectedIndex]
    }
    
    var currentWindow: Window? {
        guard let currentItem else { return nil }
        
        if case let .window(window) = currentItem {
            return window
        }
        
        return nil
    }
    
    var currentAction: CyclePanelAction? {
        guard let currentItem else { return nil }
        
        if case let .action(action) = currentItem {
            return action
        }
        
        return nil
    }
    
    func setApplication(_ application: Application) {
        self.applicationTitle = application.title

        let windows = application.getWindows()
        if windows.isEmpty {
            let action = Self.fallbackAction(
                isRunning: application.isRunning,
                isAccessibilityTrusted: AXIsProcessTrusted()
            )
            self.items = [.action(action)]
        } else {
            self.items = windows.map(CyclePanelItem.window)
        }

        self.selectedIndex = 0
    }

    // Decides what to show when there are no windows to list. Without
    // Accessibility permission, window enumeration always returns empty, so we
    // surface a permission prompt rather than a misleading "Focus app".
    nonisolated static func fallbackAction(isRunning: Bool, isAccessibilityTrusted: Bool) -> CyclePanelAction {
        guard isAccessibilityTrusted else { return .requestAccessibility }
        return isRunning ? .openWindow : .launchApp
    }
    
    func cycleNext() {
        guard !items.isEmpty else { return }
        selectedIndex = (selectedIndex + 1) % items.count
    }
    
    func reset() {
        items = []
        selectedIndex = 0
        applicationTitle = ""
    }
}
