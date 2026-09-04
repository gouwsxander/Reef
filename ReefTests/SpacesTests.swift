//
//  SpacesTests.swift
//  ReefTests
//

import Foundation
import Testing
@testable import Reef

struct SpacesTests {
    private func display(
        identifier: String,
        current: UInt64,
        spaces: [UInt64]
    ) -> [String: Any] {
        [
            "Display Identifier": identifier,
            "Current Space": ["ManagedSpaceID": current],
            "Spaces": spaces.map { ["ManagedSpaceID": $0] }
        ]
    }

    @Test func numbersDesktopsInOrderAcrossDisplays() {
        let displays = [
            display(identifier: "A", current: 7, spaces: [3, 7]),
            display(identifier: "B", current: 9, spaces: [9])
        ]

        let spaces = Spaces.parseSpaces(displays: displays) { _ in true }

        #expect(spaces.map(\.number) == [1, 2, 3])
        #expect(spaces.map(\.displayIdentifier) == ["A", "A", "B"])
    }

    @Test func flagsTheCurrentSpaceOfEachDisplay() {
        let displays = [
            display(identifier: "A", current: 7, spaces: [3, 7]),
            display(identifier: "B", current: 9, spaces: [9, 11])
        ]

        let spaces = Spaces.parseSpaces(displays: displays) { _ in true }

        #expect(spaces.filter(\.isCurrent).map(\.id) == [7, 9])
    }

    @Test func fullScreenSpacesAreListedButUnnumbered() {
        let displays = [display(identifier: "A", current: 3, spaces: [3, 4, 5])]

        // Space 4 is a full-screen space rather than a desktop.
        let spaces = Spaces.parseSpaces(displays: displays) { $0 != 4 }

        #expect(spaces.count == 3)
        #expect(spaces.map(\.number) == [1, nil, 2])
    }

    @Test func spacesWithoutAnIdentifierAreSkipped() {
        let displays: [[String: Any]] = [[
            "Display Identifier": "A",
            "Current Space": ["ManagedSpaceID": UInt64(3)],
            "Spaces": [["ManagedSpaceID": UInt64(3)], ["uuid": "no-id"]]
        ]]

        let spaces = Spaces.parseSpaces(displays: displays) { _ in true }

        #expect(spaces.map(\.id) == [3])
    }

    @Test func snapshotResolvesTheSpaceAWindowSitsOn() {
        let spaces = Spaces.parseSpaces(
            displays: [display(identifier: "A", current: 3, spaces: [3, 7])]
        ) { _ in true }
        let snapshot = SpaceSnapshot(spaces: spaces, spaceIDsByWindow: [42: 7])

        #expect(snapshot.space(for: 42)?.number == 2)
        #expect(snapshot.space(for: 42)?.isCurrent == false)
        #expect(snapshot.space(for: 99) == nil)
    }

    @Test func snapshotWithASingleSpaceNeedsNoCrossSpaceLookup() {
        let spaces = Spaces.parseSpaces(
            displays: [display(identifier: "A", current: 3, spaces: [3])]
        ) { _ in true }

        #expect(!SpaceSnapshot(spaces: spaces, spaceIDsByWindow: [:]).hasMultipleSpaces)
    }
}
