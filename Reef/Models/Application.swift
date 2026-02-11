//
//  Application.swift
//  Reef
//
//  Created by Xander Gouws on 16-09-2025.
//

import Foundation
import Cocoa


class Application {
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
    
    // Ensure application is running and refresh internal state
    func ensureRunning() -> Bool {
        guard let bundleUrl = self.bundleUrl else {
            return false
        }
        
        // Check if already running
        if let runningApp = self.runningApplication,
           runningApp.isTerminated == false {
            return true
        }
        
        // Try to find if it's running but we lost the reference
        if let bundle = Bundle(url: bundleUrl),
           let bundleIdentifier = bundle.bundleIdentifier,
           let runningApp = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).first {
            self.runningApplication = runningApp
            self.pid = runningApp.processIdentifier
            self.element = AXUIElementCreateApplication(self.pid!)
            return true
        }
        
        return false
    }
    
    func focus() {
        // Centralize relaunch logic here so callers don't need to care
        // whether the bound application is still running.
        if self.runningApplication?.isTerminated == true {
            try? self.reopen()
            return
        }
        
        // If activation fails (can happen if the process is exiting), relaunch.
        if self.runningApplication?.activate(options: []) == false {
            try? self.reopen()
        }
    }

    func activate(options: NSApplication.ActivationOptions = []) {
        if !ensureRunning() {
            // App not running, launch it
            try? reopen()
        } else {
            // App is running, just activate it
            self.runningApplication?.activate(options: options)
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
    
    func reopen() throws {
        guard let bundleUrl = self.bundleUrl else {
            throw ApplicationError.noBundleURL
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        
        let completionHandler: (NSRunningApplication?, Error?) -> Void = { runningApplication, error in
            if let runningApplication = runningApplication {
                self.runningApplication = runningApplication
                self.pid = runningApplication.processIdentifier
                self.element = AXUIElementCreateApplication(self.pid!)
            }
        }
        
        NSWorkspace.shared.openApplication(
            at: bundleUrl,
            configuration: configuration,
            completionHandler: completionHandler
        )
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
        
        return axWindows.map { axWindow in
            Window(axWindow, self)
        }
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
}


enum ApplicationError: Error {
    case noBundleURL
}
