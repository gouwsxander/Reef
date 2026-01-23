//
//  WindowSwitcherController.swift
//  Reef
//
//  Created by Xander Gouws on 23-01-2026.
//

import AppKit
import SwiftUI

@MainActor
final class WindowSwitcherController: NSObject {
    private(set) var panel: Panel!
    private let state = WindowCycleState()
    private var flagsMonitor: Any?
    private var currentApplication: Application?
    
    override init() {
        super.init()
        createPanel()
    }
    
    private func createPanel() {
        let contentRect = NSRect(x: 0, y: 0, width: 400, height: 300)
        panel = Panel(contentRect: contentRect)
        
        let contentView = WindowSwitcherPanel(state: state)
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        guard let containerView = panel.contentView else { return }
        containerView.addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // Called when user presses Ctrl+[number]
    func showSwitcher(for application: Application, startIndex: Int = 0) {
        currentApplication = application
        state.setApplication(application)
        
        // If starting index is provided (e.g., already on that app), use it
        if startIndex > 0 && startIndex < state.windows.count {
            state.selectedIndex = startIndex
        }
        
        if !panel.isVisible {
            panel.center()
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            installFlagsMonitor()
        }
    }
    
    // Called when user presses Ctrl+[number] again while panel is visible
    func cycleNext() {
        state.cycleNext()
    }
    
    // Called when user releases Ctrl
    func activateSelectedWindow() {
        guard let window = state.currentWindow else {
            hideSwitcher()
            return
        }
        
        window.focus()
        hideSwitcher()
    }
    
    private func hideSwitcher() {
        removeFlagsMonitor()
        panel.orderOut(nil)
        state.reset()
        currentApplication = nil
    }
    
    private func installFlagsMonitor() {
        guard flagsMonitor == nil else { return }
        
        flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self else { return event }
            
            let controlPressed = event.modifierFlags.contains(.control)
            
            // Control was released
            if !controlPressed {
                Task { @MainActor in
                    self.activateSelectedWindow()
                }
            }
            
            return event
        }
    }
    
    private func removeFlagsMonitor() {
        if let monitor = flagsMonitor {
            NSEvent.removeMonitor(monitor)
            flagsMonitor = nil
        }
    }
    
    deinit {
        // Capture the monitor in a local variable before deinit (while still on main actor)
        let monitor = flagsMonitor
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
}
