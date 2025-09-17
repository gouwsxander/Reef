//
//  Window.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import Foundation
import Cocoa

class Window {
    var element: AXUIElement
    var application: Application
    var cgWindowID: CGWindowID?
    
    init(_ element: AXUIElement, _ application: Application) {
        self.element = element
        self.application = application
        self.cgWindowID = element.getId()
    }
    
    func getBestTitle() -> String {
        if let title: String = self.element.getValue(.title) {
            return title
        }
        
        return application.localizedName ?? ""
    }
    
    func focus() {
        do {
            try self.element.performAction(.raise)
            self.application.focus()
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
