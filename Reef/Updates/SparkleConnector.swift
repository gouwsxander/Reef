//
//  SparkleConnector.swift
//  Reef
//
//  Owns Sparkle updater lifecycle and provides a small API for UI.
//

import Foundation
import Sparkle

@MainActor
final class SparkleConnector: ObservableObject {
    private let controller: SPUStandardUpdaterController

    init() {
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        controller = SPUStandardUpdaterController(
            startingUpdater: !isPreview,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
    }

    func checkForUpdates() {
        controller.checkForUpdates(nil)
    }
}
