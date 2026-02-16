//
//  Profile.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation

struct Profile: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var createdAt: Date
    var lastUsedAt: Date
    var profileNumber: Int?
    var numberOrder: String?
    var bindings: Bindings

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = .now,
        lastUsedAt: Date = .now,
        profileNumber: Int? = nil,
        numberOrder: String? = nil,
        bindings: Bindings = Array(repeating: nil, count: 10)
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
        self.profileNumber = profileNumber
        self.numberOrder = numberOrder
        self.bindings = Profile.normalizedBindings(bindings)
    }
}

extension Profile {
    static func normalizedBindings(_ bindings: [String?]) -> [String?] {
        if bindings.count == 10 { return bindings }
        if bindings.count > 10 { return Array(bindings.prefix(10)) }
        return bindings + Array(repeating: nil, count: 10 - bindings.count)
    }

    mutating func bind(bundleIdentifier: String, slot: Int) {
        guard (0...9).contains(slot) else { return }
        bindings = Profile.normalizedBindings(bindings)

        for index in bindings.indices {
            if bindings[index] == bundleIdentifier {
                bindings[index] = nil
            }
        }

        bindings[slot] = bundleIdentifier
    }

    mutating func unbind(slot: Int) {
        guard (0...9).contains(slot) else { return }
        bindings = Profile.normalizedBindings(bindings)
        bindings[slot] = nil
    }

    mutating func unbind(bundleIdentifier: String) {
        for index in bindings.indices {
            if bindings[index] == bundleIdentifier {
                bindings[index] = nil
            }
        }
    }

    func bundleIdentifier(for slot: Int) -> String? {
        guard (0...9).contains(slot) else { return nil }
        return Profile.normalizedBindings(bindings)[slot]
    }

    func slot(for bundleIdentifier: String) -> Int? {
        Profile.normalizedBindings(bindings).firstIndex(where: { $0 == bundleIdentifier })
    }
}
