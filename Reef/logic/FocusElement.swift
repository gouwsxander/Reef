//
//  FocusElement.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation
import Cocoa


protocol FocusElement { //: Codable {
    var title: String { get }
    var element: AXUIElement { get }
    func focus()
}
