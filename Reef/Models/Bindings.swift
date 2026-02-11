//
//  Bindings.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation
import SwiftData

@Model
final class Bindings {
    @Relationship(deleteRule: .cascade) var entries: [BindingEntry] = []

    init(entries: [BindingEntry] = []) {
        self.entries = entries
    }

    func bind(bundleIdentifier: String, slot: Int) {
        guard (0...9).contains(slot) else { return }

        // Ensure one-to-one mapping by removing any existing slot or bundle matches.
        entries.removeAll { $0.slot == slot || $0.bundleIdentifier == bundleIdentifier }
        entries.append(BindingEntry(slot: slot, bundleIdentifier: bundleIdentifier))
    }

    func unbind(slot: Int) {
        entries.removeAll { $0.slot == slot }
    }

    func unbind(bundleIdentifier: String) {
        entries.removeAll { $0.bundleIdentifier == bundleIdentifier }
    }

    func bundleIdentifier(for slot: Int) -> String? {
        entries.first(where: { $0.slot == slot })?.bundleIdentifier
    }

    func slot(for bundleIdentifier: String) -> Int? {
        entries.first(where: { $0.bundleIdentifier == bundleIdentifier })?.slot
    }
}
