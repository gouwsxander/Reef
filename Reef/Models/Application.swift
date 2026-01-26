//
//  Application.swift
//  Reef
//
//  Created by Xander Gouws on 16-09-2025.
//

import Foundation
import Cocoa


class Application: Hashable {
    var title: String
    var element: AXUIElement

    var runningApplication: NSRunningApplication
    var pid: pid_t
    var bundleUrl: URL?
    
    init(_ runningApplication: NSRunningApplication) {
        self.runningApplication = runningApplication
        
        self.pid = runningApplication.processIdentifier
        
        self.element = AXUIElementCreateApplication(self.pid)
        
        self.title = runningApplication.localizedName ?? "Unknown Application"
        self.bundleUrl = runningApplication.bundleURL
    }
    
    func focus() {
        self.activate()
    }

    func activate(options: NSApplication.ActivationOptions = []) {
        self.runningApplication.activate(options: options)
    }
    
    func getFocusedWindow() -> Window? {
        guard let windowElement: AXUIElement = element.getAttributeValue(.focusedWindow) else {
            return nil
        }
        
        return Window(windowElement, self)
    }
    
    func getFirstWindow() -> Window? {
        guard let windowElements: [AXUIElement] = element.getAttributeValue(.windows) else {
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
        
        let completionHandler: (NSRunningApplication?, Error?) -> Void = { runningApplication, error in
            if let runningApplication = runningApplication {
                self.runningApplication = runningApplication
                self.pid = runningApplication.processIdentifier
                self.element = AXUIElementCreateApplication(self.pid)
            }
        }
        
        NSWorkspace.shared.openApplication(
            at: bundleUrl,
            configuration: configuration,
            completionHandler: completionHandler
        )
    }
    
    static func == (lhs: Application, rhs: Application) -> Bool {
        return lhs.bundleUrl == rhs.bundleUrl && lhs.title == rhs.title
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.bundleUrl)
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
        // NOTE: Only returns windows in current Desktop (but multiple monitors does work)
        guard let windows: [AXUIElement] = self.element.getAttributeValue(.windows) else {
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
        var attributesRef: CFArray?
        let result = AXUIElementCopyAttributeNames(self.element, &attributesRef)
        
        guard result == .success, let attributes = attributesRef as? [String] else {
            return []
        }
        
        return attributes
    }
}


enum ApplicationError: Error {
    case noBundleURL
}
