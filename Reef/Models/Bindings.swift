//
//  Bindings.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation
import UniformTypeIdentifiers

typealias Bindings = [String?]

extension UTType {
    // Private drag payload carrying the slot an application binding is dragged from.
    // Declared in Info.plist as an exported type; never leaves the process.
    static let reefBindingSlot = UTType(exportedAs: "xandergouws.Reef.binding-slot")
}
