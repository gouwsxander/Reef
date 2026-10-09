import AppKit
import Testing
@testable import Reef

@MainActor
struct FeedbackPanelTests {
    @Test func feedbackCannotReceiveKeyboardOrMouseInput() {
        _ = NSApplication.shared
        let controller = FeedbackPanelController()
        defer { controller.panel.close() }

        #expect(!controller.panel.canBecomeKey)
        #expect(!controller.panel.canBecomeMain)
        #expect(controller.panel.ignoresMouseEvents)
        #expect(!controller.panel.hidesOnDeactivate)
        #expect(controller.panel.styleMask.contains(.nonactivatingPanel))
    }

    @Test func windowSwitcherStillAcceptsKeyboardFocus() {
        _ = NSApplication.shared
        let panel = CyclePanel(contentRect: NSRect(x: 0, y: 0, width: 400, height: 300))
        defer { panel.close() }

        #expect(panel.canBecomeKey)
        #expect(panel.canBecomeMain)
    }
}
