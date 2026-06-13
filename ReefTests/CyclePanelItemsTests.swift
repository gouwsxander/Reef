//
//  CyclePanelItemsTests.swift
//  ReefTests
//
//  When the cycle panel has no windows to show, it must distinguish
//  "Accessibility permission missing" from "app simply has no open windows".
//

import Testing
@testable import Reef

struct CyclePanelItemsTests {
    @Test func notTrusted_requestsAccessibility() {
        #expect(CyclePanelState.fallbackAction(isRunning: true, isAccessibilityTrusted: false) == .requestAccessibility)
        #expect(CyclePanelState.fallbackAction(isRunning: false, isAccessibilityTrusted: false) == .requestAccessibility)
    }

    @Test func trustedRunningNoWindows_focusApp() {
        #expect(CyclePanelState.fallbackAction(isRunning: true, isAccessibilityTrusted: true) == .openWindow)
    }

    @Test func trustedNotRunning_launchApp() {
        #expect(CyclePanelState.fallbackAction(isRunning: false, isAccessibilityTrusted: true) == .launchApp)
    }
}
