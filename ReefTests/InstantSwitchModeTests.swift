//
//  InstantSwitchModeTests.swift
//  ReefTests
//

import Foundation
import Testing
@testable import Reef

struct InstantSwitchModeTests {
    @Test func defaultsToNever() {
        let suiteName = "InstantSwitchModeTests.defaults"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        #expect(InstantSwitchMode.stored(in: defaults) == .never)
    }

    @Test func readsPersistedValue() {
        let suiteName = "InstantSwitchModeTests.persisted"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set(InstantSwitchMode.always.rawValue, forKey: InstantSwitchMode.defaultsKey)

        #expect(InstantSwitchMode.stored(in: defaults) == .always)
    }

    @Test func invalidPersistedValueFallsBackToNever() {
        let suiteName = "InstantSwitchModeTests.invalid"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        defaults.set("invalid", forKey: InstantSwitchMode.defaultsKey)

        #expect(InstantSwitchMode.stored(in: defaults) == .never)
    }

    @Test func directSwitchStartsAtFirstWindow() {
        let index = CyclePanelState.nextWindowIndex(
            windowIDs: [10, 20, 30],
            focusedWindowID: nil
        )

        #expect(index == 0)
    }

    @Test func directSwitchAdvancesFromFocusedWindowID() {
        let index = CyclePanelState.nextWindowIndex(
            windowIDs: [10, 20, 30],
            focusedWindowID: 20
        )

        #expect(index == 2)
    }

    @Test func directSwitchWrapsFromFocusedWindowID() {
        let index = CyclePanelState.nextWindowIndex(
            windowIDs: [10, 20, 30],
            focusedWindowID: 30
        )

        #expect(index == 0)
    }

    @Test func directSwitchKeepsStableOrderWhenFocusedWindowMovesToFront() {
        let initialOrder = CyclePanelState.reconciledWindowIDs(
            previousWindowIDs: [],
            availableWindowIDs: [10, 20, 30]
        )
        let reorderedWindows = CyclePanelState.reconciledWindowIDs(
            previousWindowIDs: initialOrder,
            availableWindowIDs: [20, 10, 30]
        )
        let nextIndex = CyclePanelState.nextWindowIndex(
            windowIDs: reorderedWindows.map(Optional.some),
            focusedWindowID: 20
        )
        let nextWindowID = nextIndex.map { reorderedWindows[$0] }

        #expect(reorderedWindows == [10, 20, 30])
        #expect(nextWindowID == 30)
    }
}
