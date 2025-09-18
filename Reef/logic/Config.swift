//
//  Config.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation
import Cocoa
import SwiftData


class Config {
    var name: String
    var bindings: [FocusElement?]
    var elementMap: [AXUIElement: Int]
    
    init(_ name: String) {
        self.name = name
        
        self.bindings = Array(repeating: nil, count: 10)
        self.elementMap = [:]
    }
    
    func bind(_ focusElement: FocusElement, _ index: Int) {
        if let currentIndex = elementMap[focusElement.element] {
            // If element is already bound, unbind from previous index
            bindings[currentIndex] = nil
        }
        
        self.bindings[index] = focusElement
        self.elementMap[focusElement.element] = index
    }
    
    func unbind(_ focusElement: FocusElement) {
        if let index = elementMap[focusElement.element] {
            bindings[index] = nil
            elementMap[focusElement.element] = nil
        }
    }
}
