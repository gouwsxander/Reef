//
//  Application.swift
//  Reef
//
//  Created by Xander Gouws on 16-09-2025.
//

import Foundation
import Cocoa


// NOTE: This file relies on AXUIElement helpers from logic/ApplicationServices.swift.
// NOTE: This file also references `Window` from logic/Window.swift.
class Application {
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
    
//    private enum CodingKeys: String, CodingKey {
//        case title
//        case bundleUrl
//    }
//    
//    public func encode(to encoder: any Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        
//        try container.encode(title, forKey: .title)
//        try container.encodeIfPresent(bundleUrl, forKey: .bundleUrl)
//    }
//    
//    public required init(from decoder: any Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        
//        self.title = try container.decode(String.self, forKey: .title)
//        self.bundleUrl = try container.decodeIfPresent(URL.self, forKey: .bundleUrl)
//        
//        
//    }
    

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
}


enum ApplicationError: Error {
    case noBundleURL
}
