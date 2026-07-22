//
//  InstantSwitchMode.swift
//  Reef
//

import Foundation

enum InstantSwitchMode: String, CaseIterable, Identifiable {
    static let defaultsKey = "instantSwitchMode"

    case never
    case singleWindow
    case always

    var id: Self { self }

    static func stored(in defaults: UserDefaults = .standard) -> Self {
        guard let rawValue = defaults.string(forKey: defaultsKey) else {
            return .never
        }

        return Self(rawValue: rawValue) ?? .never
    }
}
