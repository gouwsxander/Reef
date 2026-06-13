//
//  CyclePanelActivationTests.swift
//  ReefTests
//
//  Verifies the cycle panel commits the selection based on the user's
//  configured activate modifiers, not a hardcoded Control key.
//

import Testing
import AppKit
@testable import Reef

@MainActor
struct CyclePanelActivationTests {
    @Test func controlReleased_commits() {
        #expect(CyclePanelController.shouldActivateOnModifierRelease(activate: [.control], current: []))
    }

    @Test func controlHeld_doesNotCommit() {
        #expect(!CyclePanelController.shouldActivateOnModifierRelease(activate: [.control], current: [.control]))
    }

    @Test func optionActivate_optionReleased_commits() {
        // Activate modifier is Option only; Control was never involved.
        #expect(CyclePanelController.shouldActivateOnModifierRelease(activate: [.option], current: [.control]))
    }

    @Test func optionActivate_optionHeld_doesNotCommit() {
        #expect(!CyclePanelController.shouldActivateOnModifierRelease(activate: [.option], current: [.option]))
    }

    @Test func multiModifier_oneReleased_commits() {
        #expect(CyclePanelController.shouldActivateOnModifierRelease(activate: [.control, .option], current: [.control]))
    }

    @Test func multiModifier_allHeld_doesNotCommit() {
        #expect(!CyclePanelController.shouldActivateOnModifierRelease(activate: [.control, .option], current: [.control, .option]))
    }

    @Test func emptyActivate_neverCommits() {
        #expect(!CyclePanelController.shouldActivateOnModifierRelease(activate: [], current: []))
    }
}
