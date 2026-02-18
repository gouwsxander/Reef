//
//  Application.swift
//  Reef
//
//  Created by Xander Gouws on 16-09-2025.
//

import Foundation
import Cocoa


class Application {
    private static let openWindowPollIntervalNanoseconds: UInt64 = 50_000_000
    private static let openWindowPollAttempts: Int = 30
    
    var title: String
    var element: AXUIElement?

    var runningApplication: NSRunningApplication?
    var pid: pid_t?
    var bundleIdentifier: String?
    var bundleUrl: URL?
    
    init(_ runningApplication: NSRunningApplication) {
        self.runningApplication = runningApplication

        self.pid = runningApplication.processIdentifier

        self.element = AXUIElementCreateApplication(self.pid!)

        self.title = runningApplication.localizedName ?? "Unknown Application"
        self.bundleIdentifier = runningApplication.bundleIdentifier
        self.bundleUrl = runningApplication.bundleURL
    }
    
    // Initialize from URL (for loading from persistence)
    init?(url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }

        self.bundleUrl = url
        self.bundleIdentifier = Bundle(url: url)?.bundleIdentifier
        self.title = url.deletingPathExtension().lastPathComponent
        
        // Try to find running instance
        if let bundle = Bundle(url: url),
           let bundleIdentifier = bundle.bundleIdentifier,
           let runningApp = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first {
            self.runningApplication = runningApp
            self.pid = runningApp.processIdentifier
            self.element = AXUIElementCreateApplication(self.pid!)
            self.title = runningApp.localizedName ?? self.title
        } else {
            self.runningApplication = nil
            self.pid = nil
            self.element = nil
        }
    }

    convenience init?(bundleIdentifier: String) {
        if let runningApp = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleIdentifier)
            .first
        {
            self.init(runningApp)
            return
        }

        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            self.init(url: url)
            return
        }

        return nil
    }
    
//    // Ensure application is running and refresh internal state
//    func ensureRunning() -> Bool {
//        guard let bundleUrl = self.bundleUrl else {
//            return false
//        }
//        
//        // Check if already running
//        if let runningApp = self.runningApplication,
//           runningApp.isTerminated == false {
//            return true
//        }
//        
//        // Try to find if it's running but we lost the reference
//        if let bundle = Bundle(url: bundleUrl),
//           let bundleIdentifier = bundle.bundleIdentifier,
//           let runningApp = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first {
//            self.runningApplication = runningApp
//            self.pid = runningApp.processIdentifier
//            self.element = AXUIElementCreateApplication(self.pid!)
//            return true
//        }
//        
//        return false
//    }
    
    func focus() {
        self.activate()
    }
    
    var isRunning: Bool {
        refreshRunningApplication() != nil
    }

    func activate(options: NSApplication.ActivationOptions = []) {
        if let runningApplication = refreshRunningApplication() {
            // App is running, just activate it
            runningApplication.activate(options: options)
        } else {
            // App not running, launch it
            try? reopen()
        }
    }
    
    func getFocusedWindow() -> Window? {
        guard let element = element,
              let windowElement: AXUIElement = element.getAttributeValue(.focusedWindow) else {
            return nil
        }
        
        return Window(windowElement, self)
    }
    
    func getFirstWindow() -> Window? {
        guard let element = element,
              let windowElements: [AXUIElement] = element.getAttributeValue(.windows) else {
            return nil
        }
        
        if let firstWindowElement = windowElements.first {
            return Window(firstWindowElement, self)
        }
        
        return nil
    }
    
    func reopen(
        configuration: NSWorkspace.OpenConfiguration = Application.defaultOpenConfiguration(),
        completion: @escaping (Result<NSRunningApplication, Error>) -> Void
    ) throws {
        guard let bundleUrl = self.bundleUrl else {
            throw ApplicationError.noBundleURL
        }
        
        NSWorkspace.shared.openApplication(
            at: bundleUrl,
            configuration: configuration,
            completionHandler: { runningApplication, error in
                if let runningApplication {
                    self.setRunningApplication(runningApplication)
                    completion(.success(runningApplication))
                    return
                }
                
                completion(.failure(error ?? ApplicationError.openFailed))
            }
        )
    }
    
    func reopen(
        configuration: NSWorkspace.OpenConfiguration = Application.defaultOpenConfiguration()
    ) async throws -> NSRunningApplication {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try reopen(configuration: configuration) { result in
                    continuation.resume(with: result)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func reopen() throws {
        try reopen(configuration: Self.defaultOpenConfiguration()) { _ in }
    }
    
    func performNoWindowAction() async -> Bool {
        if let existingWindow = getWindows().first {
            existingWindow.focus()
            return true
        }
        
        do {
            // A foreground reopen is more reliable for apps that only create a window when active.
            _ = try await reopen(configuration: Self.defaultOpenConfiguration(activates: true))
        } catch {
            return false
        }
        
        guard let window = await waitForWindowInCurrentSpace() else {
            return false
        }
        
        window.focus()
        return true
    }
    
    static func getFrontApplication() -> Application? {
        guard let runningApplication = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        
        return Application(runningApplication)
    }
    
    static func activateOrLaunch(
        bundleIdentifier: String,
        bundleURL: URL,
        options: NSApplication.ActivationOptions = []
    ) {
        if let runningApplication = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleIdentifier)
            .first
        {
            runningApplication.activate(options: options)
            return
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.openApplication(at: bundleURL, configuration: configuration) { _, _ in }
    }

    func getAXWindows() -> [AXUIElement] {
        guard let element = element else {
            return []
        }
        
        // NOTE: Only returns windows in current Desktop (but multiple monitors does work)
        guard let windows: [AXUIElement] = element.getAttributeValue(.windows) else {
            return []
        }
        
        return windows
    }
    
    func getWindows() -> [Window] {
        let axWindows = self.getAXWindows()
        var windows = axWindows.map { axWindow in
            Window(axWindow, self)
        }
        
        // Finder can expose a trailing generic "Finder" window that is not useful for switching.
        if bundleIdentifier == "com.apple.finder",
           let lastWindow = windows.last,
           lastWindow.title == "Finder" {
            windows.removeLast()
        }
        
        return windows
    }
    
    func listAvailableAttributes() -> [String] {
        guard let element = element else {
            return []
        }
        
        var attributesRef: CFArray?
        let result = AXUIElementCopyAttributeNames(element, &attributesRef)
        
        guard result == .success, let attributes = attributesRef as? [String] else {
            return []
        }
        
        return attributes
    }
    
    @discardableResult
    private func refreshRunningApplication() -> NSRunningApplication? {
        if let runningApplication,
           runningApplication.isTerminated == false {
            return runningApplication
        }
        
        guard let bundleIdentifier else {
            setRunningApplication(nil)
            return nil
        }
        
        guard let detectedRunningApp = NSRunningApplication
            .runningApplications(withBundleIdentifier: bundleIdentifier)
            .first
        else {
            setRunningApplication(nil)
            return nil
        }
        
        setRunningApplication(detectedRunningApp)
        return detectedRunningApp
    }
    
    private func setRunningApplication(_ runningApplication: NSRunningApplication?) {
        self.runningApplication = runningApplication
        
        if let runningApplication {
            self.pid = runningApplication.processIdentifier
            self.element = AXUIElementCreateApplication(runningApplication.processIdentifier)
            self.title = runningApplication.localizedName ?? self.title
            return
        }
        
        self.pid = nil
        self.element = nil
    }
    
    private static func defaultOpenConfiguration(activates: Bool = true) -> NSWorkspace.OpenConfiguration {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = activates
        return configuration
    }
    
    private func waitForWindowInCurrentSpace() async -> Window? {
        for _ in 0..<Self.openWindowPollAttempts {
            if let window = getWindows().first {
                return window
            }
            
            try? await Task.sleep(nanoseconds: Self.openWindowPollIntervalNanoseconds)
        }
        
        return getWindows().first
    }
}


enum ApplicationError: Error {
    case noBundleURL
    case openFailed
}
