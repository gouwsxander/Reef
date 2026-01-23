//
//  WindowCycleState.swift
//  Reef
//
//  Created by Xander Gouws on 23-01-2026.
//

import Foundation

@MainActor
final class WindowCycleState: ObservableObject {
    @Published var applicationTitle: String = ""
    @Published var windows: [Window] = []
    @Published var selectedIndex: Int = 0
    
    var currentWindow: Window? {
        guard !windows.isEmpty, selectedIndex < windows.count else { return nil }
        return windows[selectedIndex]
    }
    
    func setApplication(_ application: Application) {
        self.applicationTitle = application.title
        self.windows = application.getWindows()
        self.selectedIndex = 0
    }
    
    func cycleNext() {
        guard !windows.isEmpty else { return }
        selectedIndex = (selectedIndex + 1) % windows.count
    }
    
    func reset() {
        windows = []
        selectedIndex = 0
        applicationTitle = ""
    }
}
