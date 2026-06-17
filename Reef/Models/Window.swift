//
//  Window.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import Foundation
import Cocoa


class Window: Identifiable {
    // Prefer the real CGWindowID, but fall back to a per-instance unique id so
    // two windows never collide (the private _AXUIElementGetWindow can fail and
    // return nil, which previously made every such window share id 0).
    var id: String {
        if let cgWindowID, cgWindowID != 0 { return "cg-\(cgWindowID)" }
        return "ax-\(fallbackID.uuidString)"
    }
    var element: AXUIElement
    var cgWindowID: CGWindowID?
    var application: Application
    private let fallbackID = UUID()

    init(_ element: AXUIElement, _ application: Application) {
        self.element = element
        self.cgWindowID = element.getWindowID()
        self.application = application
    }
    
    var title: String {
        if let title: String = self.element.getAttributeValue(.title) {
            return title
        }
        
        return application.title
    }
    
    func focus() {
        do {
            try self.element.performAction(.raise)
            self.application.activate()
        } catch {
            try? self.application.reopen()
        }
    }
    
    static func getFrontWindow() -> Window? {
        guard let frontApplication = Application.getFrontApplication() else {
            return nil
        }
        
        if let focusedWindow = frontApplication.getFocusedWindow() {
            return focusedWindow
        }
        
        if let firstWindow = frontApplication.getFirstWindow() {
            return firstWindow
        }
        
        return nil
    }
}
