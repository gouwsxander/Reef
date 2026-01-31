//
//  Bindings.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation
import Cocoa
import SwiftData

@Model
class Bindings: ObservableObject {
    var name: String
    var createdDate: Date?
    var lastUsedDate: Date?
    var numberOrder: String? // nil means "use default"
    
    // Store bindings as URLs for persistence (SwiftData compatible)
    var bindingURLs: [Int: URL]
    
    // Runtime state (not persisted, transient)
    @Transient var applications: [Application?] = Array(repeating: nil, count: 10)
    @Transient var indices: [Application: Int] = [:]

    init(_ name: String, numberOrder: String? = nil) {
        self.name = name
        self.lastUsedDate = Date.now
        self.createdDate = Date.now
        self.numberOrder = numberOrder
        self.bindingURLs = [:]
    }
    
    // Load applications from URLs
    func loadApplications() {
        applications = Array(repeating: nil, count: 10)
        indices = [:]
        
        for (index, url) in bindingURLs {
            if let app = Application(url: url) {
                applications[index] = app
                indices[app] = index
            }
        }
        
        objectWillChange.send()
    }
    
    func bind(_ application: Application, _ index: Int) {
        // Remove current binding at this index if exists
        if let currentApp = applications[index] {
            indices[currentApp] = nil
        }
        
        // Remove previous index for this application if exists
        if let currentIndex = indices[application] {
            applications[currentIndex] = nil
            bindingURLs.removeValue(forKey: currentIndex)
        }

        applications[index] = application
        indices[application] = index
        
        if let url = application.bundleUrl {
            bindingURLs[index] = url
        }
        
        objectWillChange.send()
    }
    
    func unbind(_ application: Application) {
        if let index = indices[application] {
            applications[index] = nil
            indices[application] = nil
            bindingURLs.removeValue(forKey: index)
            
            objectWillChange.send()
        }
    }
    
    subscript(index: Int) -> Application? {
        return applications[index]
    }
    
    subscript(application: Application) -> Int? {
        return indices[application]
    }
}
