//
//  CyclePanelState.swift
//  Reef
//
//  Created by Xander Gouws on 23-01-2026.
//

import Foundation
import CoreGraphics

enum CyclePanelAction {
    case launchApp
    case openWindow
    
    var title: String {
        switch self {
        case .launchApp:
            return "Launch app"
        case .openWindow:
            return "Focus app"
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
    
    func setApplication(_ application: Application, windows providedWindows: [Window]? = nil) {
        self.applicationTitle = application.title
        
        let windows = providedWindows ?? application.getWindows()
        if windows.isEmpty {
            let action: CyclePanelAction = application.isRunning ? .openWindow : .launchApp
            self.items = [.action(action)]
        } else {
            self.items = windows.map(CyclePanelItem.window)
        }
        
        self.selectedIndex = 0
    }
    
    func cycleNext() {
        guard !items.isEmpty else { return }
        selectedIndex = (selectedIndex + 1) % items.count
    }

    nonisolated static func nextWindowIndex(
        windowIDs: [CGWindowID?],
        focusedWindowID: CGWindowID?
    ) -> Int? {
        guard !windowIDs.isEmpty else { return nil }
        guard let focusedWindowID,
              let focusedIndex = windowIDs.firstIndex(of: focusedWindowID) else {
            return 0
        }

        return (focusedIndex + 1) % windowIDs.count
    }
    nonisolated static func reconciledWindowIDs(
        previousWindowIDs: [CGWindowID],
        availableWindowIDs: [CGWindowID]
    ) -> [CGWindowID] {
        let availableWindowIDSet = Set(availableWindowIDs)
        var includedWindowIDs = Set<CGWindowID>()

        let existingWindowIDs = previousWindowIDs.filter {
            availableWindowIDSet.contains($0) && includedWindowIDs.insert($0).inserted
        }
        let newWindowIDs = availableWindowIDs.filter {
            includedWindowIDs.insert($0).inserted
        }

        return existingWindowIDs + newWindowIDs
    }
    
    func reset() {
        items = []
        selectedIndex = 0
        applicationTitle = ""
    }
}
