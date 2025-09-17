//
//  Application.swift
//  Reef
//
//  Created by Xander Gouws on 16-09-2025.
//

import Foundation
import Cocoa

class Application {
    var runningApplication: NSRunningApplication
    var pid: pid_t
    var element: AXUIElement
    var localizedName: String?
    var bundleUrl: URL?
    
    init(_ runningApplication: NSRunningApplication) {
        self.runningApplication = runningApplication
        
        self.pid = runningApplication.processIdentifier
        
        self.element = AXUIElementCreateApplication(self.pid)
        
        self.localizedName = runningApplication.localizedName
        self.bundleUrl = runningApplication.bundleURL
    }
    
    func focus(allWindows: Bool = false) {
        self.runningApplication.activate(options: allWindows ? .activateAllWindows : [])
    }
    
    func getFocusedWindow() -> Window? {
        guard let windowElement: AXUIElement = element.getValue(.focusedWindow) else {
            print("Couldn't get focused window")
            return nil
        }
        
        return Window(windowElement, self)
    }
    
    func getFirstWindow() -> Window? {
        guard let windowElements: [AXUIElement] = element.getValue(.windows) else {
            print("Couldn't get window list")
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
