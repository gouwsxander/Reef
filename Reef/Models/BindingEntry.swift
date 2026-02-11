//
//  BindingEntry.swift
//  Reef
//
//  Created by Xander Gouws on 11-02-2026.
//

import Foundation
import SwiftData

@Model
final class BindingEntry {
    var slot: Int
    var bundleIdentifier: String

    init(slot: Int, bundleIdentifier: String) {
        self.slot = slot
        self.bundleIdentifier = bundleIdentifier
    }
}
