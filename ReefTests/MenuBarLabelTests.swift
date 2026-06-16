//
//  MenuBarLabelTests.swift
//  ReefTests
//
//  The menu-bar label text uses the current profile's name.
//

import Testing
@testable import Reef

struct MenuBarLabelTests {
    @Test func profileWithNumber_showsNameOnly() {
        let profile = Profile(name: "Coding", profileNumber: 1)
        #expect(MenuBarLabel.labelText(for: profile) == "Coding")
    }

    @Test func profileWithoutNumber_showsNameOnly() {
        let profile = Profile(name: "Coding", profileNumber: nil)
        #expect(MenuBarLabel.labelText(for: profile) == "Coding")
    }

    @Test func noProfile_isEmpty() {
        #expect(MenuBarLabel.labelText(for: nil) == "")
    }
}
