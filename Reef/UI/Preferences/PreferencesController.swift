//
//  PreferencesController.swift
//  Reef
//
//  Created by Xander Gouws on 28-01-2026.
//

import SwiftUI

private enum PreferencesTab: String, CaseIterable {
    case general
    case profiles
    case shortcuts

    var title: String {
        switch self {
        case .general: "General"
        case .profiles: "Profiles"
        case .shortcuts: "Shortcuts"
        }
    }

    var systemImageName: String {
        switch self {
        case .general: "gear"
        case .profiles: "person.crop.rectangle.stack"
        case .shortcuts: "command"
        }
    }

    var itemIdentifier: NSToolbarItem.Identifier {
        NSToolbarItem.Identifier("Reef.Preferences.\(rawValue)")
    }

    static func tab(for itemIdentifier: NSToolbarItem.Identifier) -> PreferencesTab? {
        allCases.first { $0.itemIdentifier == itemIdentifier }
    }
}

@MainActor
class PreferencesController {
    private var settingsWindow: NSWindow?
    private var toolbarDelegate: PreferencesToolbarDelegate?
    private var profileManager: ProfileManager?
    private var sparkleConnector: SparkleConnector?
    private var selectedTab = PreferencesTab.general
    private var didTemporarilyLowerSettingsWindow = false
    private var didSettingsWindowResignKeyWhileLowered = false
    private var didBecomeKeyObserver: Any?
    private var didResignKeyObserver: Any?
    private var restoreFloatingLevelTask: Task<Void, Never>?
    
    private func configureSettingsWindow(_ window: NSWindow) {
        window.collectionBehavior = [.moveToActiveSpace, .fullScreenAuxiliary]
        window.isRestorable = false
        window.level = .floating
    }

    deinit {
        restoreFloatingLevelTask?.cancel()

        if let didBecomeKeyObserver {
            NotificationCenter.default.removeObserver(didBecomeKeyObserver)
        }
        if let didResignKeyObserver {
            NotificationCenter.default.removeObserver(didResignKeyObserver)
        }
    }

    func openSettingsWindow(profileManager: ProfileManager, sparkleConnector: SparkleConnector) {
        self.profileManager = profileManager
        self.sparkleConnector = sparkleConnector

        NSApp.activate(ignoringOtherApps: true)

        if let settingsWindow {
            bringSettingsWindowToFront(settingsWindow)
            return
        }

        let window = NSWindow()
        let toolbarDelegate = PreferencesToolbarDelegate(controller: self)
        let toolbar = NSToolbar(identifier: "Reef.PreferencesToolbar")

        window.title = selectedTab.title
        window.titleVisibility = .visible
        window.titlebarAppearsTransparent = false
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.toolbarStyle = .preference

        toolbar.delegate = toolbarDelegate
        toolbar.displayMode = .iconAndLabel
        toolbar.allowsUserCustomization = false
        toolbar.autosavesConfiguration = false
        toolbar.selectedItemIdentifier = selectedTab.itemIdentifier
        window.toolbar = toolbar

        configureSettingsWindow(window)
        observeSettingsWindowFocus(window)
        settingsWindow = window
        self.toolbarDelegate = toolbarDelegate
        selectTab(selectedTab)
        window.center()

        bringSettingsWindowToFront(window)
    }

    func temporarilyAllowUpdateWindowToFloatAboveSettings() {
        guard let settingsWindow else { return }

        didTemporarilyLowerSettingsWindow = true
        didSettingsWindowResignKeyWhileLowered = false
        restoreFloatingLevelTask?.cancel()
        restoreFloatingLevelTask = nil
        settingsWindow.level = .normal
    }

    fileprivate func selectTab(_ tab: PreferencesTab) {
        guard let settingsWindow, let profileManager, let sparkleConnector else { return }

        selectedTab = tab
        settingsWindow.title = tab.title
        settingsWindow.toolbar?.selectedItemIdentifier = tab.itemIdentifier
        let topEdge = settingsWindow.frame.maxY

        let hostingController = NSHostingController(
            rootView: preferencesContent(for: tab)
                .environmentObject(profileManager)
                .environmentObject(sparkleConnector)
        )
        settingsWindow.contentViewController = hostingController
        hostingController.view.layoutSubtreeIfNeeded()

        let fittingSize = hostingController.view.fittingSize
        if fittingSize.width > 0, fittingSize.height > 0 {
            setContentSize(fittingSize, for: settingsWindow, preservingTopEdge: topEdge)
        }
    }

    private func setContentSize(_ contentSize: NSSize, for window: NSWindow, preservingTopEdge topEdge: CGFloat) {
        let oldFrame = window.frame
        let newFrameSize = window.frameRect(forContentRect: NSRect(origin: .zero, size: contentSize)).size
        let newFrame = NSRect(
            x: oldFrame.minX,
            y: window.isVisible ? topEdge - newFrameSize.height : oldFrame.minY,
            width: newFrameSize.width,
            height: newFrameSize.height
        )

        window.setFrame(newFrame, display: true, animate: false)
    }

    @ViewBuilder
    private func preferencesContent(for tab: PreferencesTab) -> some View {
        switch tab {
        case .general:
            PreferencesGeneralView()
                .frame(width: 650)
        case .profiles:
            PreferencesProfilesView()
                .frame(width: 650)
        case .shortcuts:
            PreferencesShortcutsView()
                .frame(width: 650)
        }
    }

    private func bringSettingsWindowToFront(_ window: NSWindow) {
        restoreFloatingLevelIfNeeded()
        NSApp.activate(ignoringOtherApps: true)
        window.orderFrontRegardless()
        window.makeKeyAndOrderFront(nil)
    }

    private func observeSettingsWindowFocus(_ window: NSWindow) {
        didBecomeKeyObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }

                if self.didSettingsWindowResignKeyWhileLowered {
                    self.restoreFloatingLevelAfterUpdateWindowHandoff()
                }
            }
        }

        didResignKeyObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification,
            object: window,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }

                self.restoreFloatingLevelTask?.cancel()
                self.restoreFloatingLevelTask = nil

                if self.didTemporarilyLowerSettingsWindow {
                    self.didSettingsWindowResignKeyWhileLowered = true
                }
            }
        }
    }

    private func restoreFloatingLevelAfterUpdateWindowHandoff() {
        restoreFloatingLevelTask?.cancel()
        restoreFloatingLevelTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }

            self.restoreFloatingLevelIfNeeded()
        }
    }

    private func restoreFloatingLevelIfNeeded() {
        guard didTemporarilyLowerSettingsWindow, let settingsWindow else { return }

        restoreFloatingLevelTask?.cancel()
        restoreFloatingLevelTask = nil
        settingsWindow.level = .floating
        didTemporarilyLowerSettingsWindow = false
        didSettingsWindowResignKeyWhileLowered = false
    }
}

@MainActor
private final class PreferencesToolbarDelegate: NSObject, NSToolbarDelegate {
    private weak var controller: PreferencesController?

    init(controller: PreferencesController) {
        self.controller = controller
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        PreferencesTab.allCases.map(\.itemIdentifier)
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        PreferencesTab.allCases.map(\.itemIdentifier)
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        PreferencesTab.allCases.map(\.itemIdentifier)
    }

    func toolbar(
        _ toolbar: NSToolbar,
        itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        guard let tab = PreferencesTab.tab(for: itemIdentifier) else { return nil }

        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = tab.title
        item.paletteLabel = tab.title
        item.toolTip = tab.title
        item.image = NSImage(systemSymbolName: tab.systemImageName, accessibilityDescription: tab.title)
        item.target = self
        item.action = #selector(selectTab(_:))
        return item
    }

    @objc private func selectTab(_ sender: NSToolbarItem) {
        guard let tab = PreferencesTab.tab(for: sender.itemIdentifier) else { return }
        controller?.selectTab(tab)
    }
}
