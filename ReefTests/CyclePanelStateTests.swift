//
//  CyclePanelStateTests.swift
//  ReefTests
//
//  Cycling moves the selection forward (clockwise) and backward
//  (anti-clockwise), wrapping at both ends.
//

import Testing
@testable import Reef

@MainActor
struct CyclePanelStateTests {
    private func makeState(itemCount: Int) -> CyclePanelState {
        let state = CyclePanelState()
        state.items = Array(repeating: .action(.openWindow), count: itemCount)
        state.selectedIndex = 0
        return state
    }

    @Test func cyclePrevious_fromFirst_wrapsToLast() {
        let state = makeState(itemCount: 3)
        state.cyclePrevious()
        #expect(state.selectedIndex == 2)
    }

    @Test func cyclePrevious_fromMiddle_movesBackOne() {
        let state = makeState(itemCount: 3)
        state.selectedIndex = 2
        state.cyclePrevious()
        #expect(state.selectedIndex == 1)
    }

    @Test func cyclePrevious_whenEmpty_staysAtZero() {
        let state = CyclePanelState()
        state.cyclePrevious()
        #expect(state.selectedIndex == 0)
    }

    @Test func cyclePrevious_thenCycleNext_returnsToStart() {
        let state = makeState(itemCount: 4)
        state.cyclePrevious()
        state.cycleNext()
        #expect(state.selectedIndex == 0)
    }
}
