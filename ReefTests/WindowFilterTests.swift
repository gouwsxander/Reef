//
//  WindowFilterTests.swift
//  ReefTests
//
//  The cycle panel must drop junk windows (e.g. Chromium's hidden helper
//  windows: empty title + AXUnknown subrole) while keeping real ones.
//

import Testing
import AppKit
@testable import Reef

struct WindowFilterTests {
    private let standard = NSAccessibility.Subrole.standardWindow.rawValue

    @Test func standardWindow_keptEvenWithoutTitle() {
        #expect(Application.isRelevantWindow(subrole: standard, title: ""))
        #expect(Application.isRelevantWindow(subrole: standard, title: nil))
    }

    @Test func unknownSubroleEmptyTitle_dropped() {
        #expect(!Application.isRelevantWindow(subrole: "AXUnknown", title: ""))
        #expect(!Application.isRelevantWindow(subrole: "AXUnknown", title: nil))
    }

    @Test func titledWindow_keptRegardlessOfSubrole() {
        #expect(Application.isRelevantWindow(subrole: "AXUnknown", title: "(2592) YouTube - Brave"))
    }
}
