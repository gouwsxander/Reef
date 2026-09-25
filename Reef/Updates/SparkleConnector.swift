//
//  SparkleConnector.swift
//  Reef
//
//  Owns Sparkle updater lifecycle and provides a small API for UI.
//

import Foundation
import AppKit
import Sparkle

@MainActor
final class SparkleConnector: ObservableObject {
    private let controller: SPUStandardUpdaterController
    private let isPreview: Bool
    private var didFinishLaunchingObserver: Any?
    private var didStartUpdater = false

    @Published private(set) var canCheckForUpdates = false
    private var canCheckObservation: NSKeyValueObservation?

    init() {
        isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        controller = SPUStandardUpdaterController(
            startingUpdater: false,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )

        guard !isPreview else { return }

        canCheckObservation = controller.updater.observe(
            \.canCheckForUpdates,
            options: [.initial, .new]
        ) { [weak self] updater, _ in
            Task { @MainActor in
                self?.canCheckForUpdates = updater.canCheckForUpdates
            }
        }

        didFinishLaunchingObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didFinishLaunchingNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.startUpdaterIfNeeded()
            }
        }
    }

    deinit {
        if let didFinishLaunchingObserver {
            NotificationCenter.default.removeObserver(didFinishLaunchingObserver)
        }
    }

    func checkForUpdates() {
        guard !isPreview else { return }
        startUpdaterIfNeeded()
        NSApp.activate(ignoringOtherApps: true)
        controller.checkForUpdates(nil)
    }

    private func startUpdaterIfNeeded() {
        guard !didStartUpdater else { return }
        controller.startUpdater()
        didStartUpdater = true
    }
}
