//
//  Bindings.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation
import SwiftData

@Model
class Profile {
    var name: String
    var number: Int?
    var numberOrder: String?
    var bindings: Bindings

    init(_ name: String) {
        self.name = name
        self.numberOrder = nil
        self.number = nil
        self.bindings = Bindings()
    }
}
