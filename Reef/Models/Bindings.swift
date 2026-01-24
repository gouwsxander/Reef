//
//  Bindings.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation
import Cocoa
import SwiftData


class Bindings {
    @Attribute(.unique) var name: String
    var lastUsedDate: Date?
    
    private var applications: [Application?]
    private var indices: [Application: Int]

    init(_ name: String) {
        self.name = name
        self.lastUsedDate = Date.now

        self.applications = Array(repeating: nil, count: 10)
        self.indices = [:]
    }
    
    func bind(_ application: Application, _ index: Int) {
        if let currentIndex = indices[application] {
            applications[currentIndex] = nil
        }

        applications[index] = application
        indices[application] = index
    }
    
    func unbind(_ application: Application) {
        if let index = indices[application] {
            applications[index] = nil
            indices[application] = nil
        }
    }
    
    subscript(index: Int) -> Application? {
        return applications[index]
    }
    
    subscript(application: Application) -> Int? {
        return indices[application]
    }
}
