//
//  Bindings.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation
import SwiftData

@Model
class Bindings {
    var applications: [URL?]
    var indices: [URL: Int]

    init() {
        self.applications = Array(repeating: nil, count: 10)
        self.indices = [:]
    }
    
    func bind(_ application: Application, _ index: Int) throws {
        // Get bundle URL or else throw
        guard let url = application.bundleUrl else {
            throw ApplicationError.noBundleURL
        }
        
        // Remove current binding at this index if exists
        if let currentUrl = applications[index] {
            indices[currentUrl] = nil
        }
        
        // Remove previous index for this application if exists
        if let currentIndex = indices[url] {
            applications[currentIndex] = nil
        }

        applications[index] = url
        indices[url] = index
    }
    
    func unbind(_ application: Application) throws {
        // Get bundle URL or else throw
        guard let url = application.bundleUrl else {
            throw ApplicationError.noBundleURL
        }
        
        if let index = indices[url] {
            applications[index] = nil
            indices[url] = nil
        }
    }
    
    subscript(index: Int) -> Application? {
        if let url = applications[index] {
            return Application(url)
        }
        
        return nil
    }
    
    subscript(application: Application) -> Int? {
        // Get bundle URL or else throw
        guard let url = application.bundleUrl else {
            return nil
        }
        
        return indices[url]
    }
}
