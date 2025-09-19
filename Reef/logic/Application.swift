//
//  Application.swift
//  Reef
//
//  Created by Xander Gouws on 16-09-2025.
//

import Foundation
import Cocoa


class Application: FocusElement {
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
        // Should update to activate with options decided by user
        // e.g., .activateAllWindows
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
        
    static func getFrontApplication() -> Application? {
        guard let runningApplication = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        
        return Application(runningApplication)
    }
}


enum ApplicationError: Error {
    case noBundleURL
}
