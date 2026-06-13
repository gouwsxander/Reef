//
//  CyclePanelController.swift
//  Reef
//
//  Created by Xander Gouws on 23-01-2026.
//

import AppKit
import SwiftUI


@MainActor
final class CyclePanelController: NSObject {
    private(set) var panel: CyclePanel!
    private let state = CyclePanelState()
    private var flagsMonitor: Any?
    private var keyDownMonitor: Any?
    private var currentApplication: Application?
    private var panelAnchorCenter: CGPoint?

    // The modifiers that must be held to keep the switcher open. Captured when
    // the panel is shown so releasing them commits the selection — this honours
    // the user's customizable activate modifiers instead of assuming Control.
    private var activateModifiers: NSEvent.ModifierFlags = [.control]

    private let panelContentWidth: CGFloat = 400
    private let maxPanelFrameHeightCap: CGFloat = 520

    // Keep these aligned with CyclePanelView.
    private let headerHeight: CGFloat = 44
    private let dividerHeight: CGFloat = 1
    private let rowHeight: CGFloat = 44
    private let rowSpacing: CGFloat = 4
    private let listVerticalPadding: CGFloat = 8

    private var minPanelContentHeight: CGFloat {
        // Minimum height that still matches the layout for one row.
        headerHeight + dividerHeight + (listVerticalPadding * 2) + rowHeight
    }
    
    override init() {
        super.init()
        createPanel()
    }
    
    private func createPanel() {
        let contentRect = NSRect(x: 0, y: 0, width: panelContentWidth, height: 300)
        panel = CyclePanel(contentRect: contentRect)
        
        let contentView = CyclePanelView(state: state)
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
        if startIndex > 0 && startIndex < state.items.count {
            state.selectedIndex = startIndex
        }
        
        if !panel.isVisible {
            activateModifiers = AppDelegate.modifierManager?.activateModifiers ?? [.control]
            panel.center()
            panelAnchorCenter = CGPoint(x: panel.frame.midX, y: panel.frame.midY)
            updatePanelSize()
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            installFlagsMonitor()
            installKeyDownMonitor()
        } else {
            if panelAnchorCenter == nil {
                panelAnchorCenter = CGPoint(x: panel.frame.midX, y: panel.frame.midY)
            }
            updatePanelSize()
        }
    }

    private func updatePanelSize() {
        let itemCount = state.items.count
        let rowsHeight = CGFloat(itemCount) * rowHeight
        let spacingHeight = CGFloat(max(0, itemCount - 1)) * rowSpacing
        let listHeight = rowsHeight + spacingHeight + (listVerticalPadding * 2)
        let desiredContentHeight = headerHeight + dividerHeight + listHeight

        let maxContentHeightByScreen: CGFloat = {
            let visibleFrameHeight = (panel.screen ?? NSScreen.main)?.visibleFrame.height ?? maxPanelFrameHeightCap
            let maxFrameHeight = min(maxPanelFrameHeightCap, visibleFrameHeight * 0.6)
            let maxFrameRect = NSRect(x: 0, y: 0, width: panelContentWidth, height: maxFrameHeight)
            return panel.contentRect(forFrameRect: maxFrameRect).height
        }()

        let clampedContentHeight = max(minPanelContentHeight, min(desiredContentHeight, maxContentHeightByScreen))
        let targetContentRect = NSRect(x: 0, y: 0, width: panelContentWidth, height: clampedContentHeight)
        let targetFrameSize = panel.frameRect(forContentRect: targetContentRect).size

        // Keep the panel pinned to the same center while Ctrl is held.
        let center = panelAnchorCenter ?? CGPoint(x: panel.frame.midX, y: panel.frame.midY)
        let newOrigin = CGPoint(
            x: center.x - targetFrameSize.width / 2,
            y: center.y - targetFrameSize.height / 2
        )
        let newFrame = NSRect(origin: newOrigin, size: targetFrameSize)

        panel.setFrame(newFrame, display: true, animate: false)
    }
    
    // Called when user presses Ctrl+[number] again while panel is visible
    func cycleNext() {
        state.cycleNext()
    }

    // The switcher commits its selection once the activate modifiers are no
    // longer all held. Returns false when no activate modifiers are configured,
    // so a stray flagsChanged event can't dismiss the panel immediately.
    static func shouldActivateOnModifierRelease(
        activate: NSEvent.ModifierFlags,
        current: NSEvent.ModifierFlags
    ) -> Bool {
        guard !activate.isEmpty else { return false }
        return !activate.isSubset(of: current)
    }
    
    func isShowingSwitcher(for application: Application) -> Bool {
        guard let currentApplication else { return false }
        
        if let currentBundleID = currentApplication.bundleIdentifier,
           let targetBundleID = application.bundleIdentifier {
            return currentBundleID == targetBundleID
        }
        
        if let currentURL = currentApplication.bundleUrl,
           let targetURL = application.bundleUrl {
            return currentURL == targetURL
        }
        
        return currentApplication.title == application.title
    }
    
    // Called when user releases Ctrl
    func activateSelectedWindow() {
        guard let item = state.currentItem else {
            hideSwitcher()
            return
        }
        
        switch item {
        case .window(let window):
            window.focus()
            hideSwitcher()
        case .action:
            let application = currentApplication
            hideSwitcher()
            
            Task { @MainActor in
                guard let application else {
                    NSSound.beep()
                    return
                }
                
                let success = await application.performNoWindowAction()
                if !success {
                    NSSound.beep()
                }
            }
        }
    }
    
    private func hideSwitcher() {
        removeFlagsMonitor()
        removeKeyDownMonitor()
        panel.orderOut(nil)
        state.reset()
        currentApplication = nil
        panelAnchorCenter = nil
    }
    
    private func installFlagsMonitor() {
        guard flagsMonitor == nil else { return }
        
        flagsMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            guard let self = self else { return event }

            // The activate modifiers were released — commit the selection.
            if Self.shouldActivateOnModifierRelease(activate: self.activateModifiers, current: event.modifierFlags) {
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

    private func installKeyDownMonitor() {
        guard keyDownMonitor == nil else { return }

        keyDownMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }

            // Escape closes the switcher.
            if self.panel.isVisible, event.keyCode == 53 {
                Task { @MainActor in
                    self.hideSwitcher()
                }
                return nil
            }

            return event
        }
    }

    private func removeKeyDownMonitor() {
        if let monitor = keyDownMonitor {
            NSEvent.removeMonitor(monitor)
            keyDownMonitor = nil
        }
    }
    
    deinit {
        // Capture the monitor in a local variable before deinit (while still on main actor)
        let monitor = flagsMonitor
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }

        let keyMonitor = keyDownMonitor
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
        }
    }
}
