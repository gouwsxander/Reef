//
//  ProfileBindingTests.swift
//  ReefTests
//

import Testing
@testable import Reef

struct ProfileBindingTests {
    @Test func movingOntoEmptySlotRelocatesBinding() {
        var profile = Profile(name: "Test")
        profile.bind(bundleIdentifier: "com.example.editor", slot: 1)

        profile.moveBinding(from: 1, to: 4)

        #expect(profile.bundleIdentifier(for: 1) == nil)
        #expect(profile.bundleIdentifier(for: 4) == "com.example.editor")
    }

    @Test func movingOntoOccupiedSlotSwapsBindings() {
        var profile = Profile(name: "Test")
        profile.bind(bundleIdentifier: "com.example.editor", slot: 1)
        profile.bind(bundleIdentifier: "com.example.browser", slot: 2)

        profile.moveBinding(from: 1, to: 2)

        #expect(profile.bundleIdentifier(for: 1) == "com.example.browser")
        #expect(profile.bundleIdentifier(for: 2) == "com.example.editor")
    }

    @Test func movingOntoItselfLeavesBindingsUnchanged() {
        var profile = Profile(name: "Test")
        profile.bind(bundleIdentifier: "com.example.editor", slot: 3)

        profile.moveBinding(from: 3, to: 3)

        #expect(profile.bundleIdentifier(for: 3) == "com.example.editor")
    }

    @Test func movingOutOfRangeIsIgnored() {
        var profile = Profile(name: "Test")
        profile.bind(bundleIdentifier: "com.example.editor", slot: 0)

        profile.moveBinding(from: 0, to: 10)
        profile.moveBinding(from: -1, to: 0)

        #expect(profile.bundleIdentifier(for: 0) == "com.example.editor")
        #expect(profile.bindings.compactMap { $0 } == ["com.example.editor"])
    }

    @Test func bindingAnApplicationClearsItsPreviousSlot() {
        var profile = Profile(name: "Test")
        profile.bind(bundleIdentifier: "com.example.editor", slot: 1)

        profile.bind(bundleIdentifier: "com.example.editor", slot: 7)

        #expect(profile.bundleIdentifier(for: 1) == nil)
        #expect(profile.bundleIdentifier(for: 7) == "com.example.editor")
    }
}
