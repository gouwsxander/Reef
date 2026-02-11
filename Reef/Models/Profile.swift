//
//  Profile.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation
import SwiftData

@Model
final class Profile {
    var name: String
    var createdDate: Date
    var lastUsedDate: Date
    var profileNumber: Int?
    var numberOrder: String?
    @Relationship(deleteRule: .cascade) var bindings: Bindings

    init(
        name: String,
        createdDate: Date = .now,
        lastUsedDate: Date = .now,
        profileNumber: Int? = nil,
        numberOrder: String? = nil,
        bindings: Bindings = Bindings()
    ) {
        self.name = name
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
        self.profileNumber = profileNumber
        self.numberOrder = numberOrder
        self.bindings = bindings
    }
}
