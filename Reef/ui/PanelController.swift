//
//  PanelController.swift
//  Reef
//
//  Created by Xander Gouws on 19-01-2026.
//

import AppKit
import SwiftUI

@MainActor
class PanelController: NSObject {
    private(set) var panel: Panel!
    private let model = SwitcherViewModel()
    private let dataProvider: () -> [SwitcherItem]
    private var flagsChangedMonitor: Any?
    
    override init() {
        self.dataProvider = foobar
        super.init()
        createPanel()
    }
    
    func createPanel() {
        let contentRect = NSRect(x: 0, y: 0, width: 400, height: 300)
        panel = Panel(contentRect: contentRect)

        let contentView = PanelUI(model: model)
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

        panel.center()
    }

    func handleSwitcherHotkey() {
        if panel.isVisible {
            model.cycle()
        } else {
            showSwitcher()
        }
    }

    func showSwitcher() {
        model.title = "App Name"
        model.setItems(dataProvider())
        panel.center()
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        installFlagsChangedMonitorIfNeeded()
    }

    func hideSwitcher() {
        removeFlagsChangedMonitorIfNeeded()
        panel.orderOut(nil)
    }

    private func installFlagsChangedMonitorIfNeeded() {
        guard flagsChangedMonitor == nil else { return }
        flagsChangedMonitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged]) { [weak self] event in
            guard let self else { return event }
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if !flags.contains(.control) {
                self.hideSwitcher()
            }
            return event
        }
    }

    private func removeFlagsChangedMonitorIfNeeded() {
        if let flagsChangedMonitor {
            NSEvent.removeMonitor(flagsChangedMonitor)
            self.flagsChangedMonitor = nil
        }
    }
}
