//
//  Window.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import Foundation
import Cocoa


class Window: Identifiable {
    var id: CGWindowID { cgWindowID ?? 0 }
    // Windows on another space are not exposed through accessibility, so they are
    // tracked by their CoreGraphics identifier until their space is activated.
    var element: AXUIElement?
    var cgWindowID: CGWindowID?
    var application: Application
    let space: SpaceSnapshot.Space?

    private static let spaceActivationAttempts = 20
    private static let spaceActivationPollInterval: UInt64 = 50_000_000

    init(_ element: AXUIElement, _ application: Application, space: SpaceSnapshot.Space? = nil) {
        self.element = element
        self.cgWindowID = element.getWindowID()
        self.application = application
        self.space = space
    }

    // A window discovered on another space, where only its identifier is known.
    init(cgWindowID: CGWindowID, application: Application, space: SpaceSnapshot.Space) {
        self.element = nil
        self.cgWindowID = cgWindowID
        self.application = application
        self.space = space
    }

    var title: String {
        if let title: String = self.element?.getAttributeValue(.title), !title.isEmpty {
            return title
        }

        // A window on another space cannot report its title without Screen Recording
        // access, so fall back to the last title seen while it was reachable.
        if let cgWindowID, let rememberedTitle = Self.rememberedTitle(for: cgWindowID) {
            return rememberedTitle
        }

        return application.title
    }

    // Records the current title so the window keeps its name once it leaves the
    // active space and accessibility stops reporting it.
    func rememberTitle() {
        guard let cgWindowID,
              let title: String = self.element?.getAttributeValue(.title),
              !title.isEmpty else {
            return
        }

        Self.titleCache.setObject(title as NSString, forKey: NSNumber(value: cgWindowID))
    }

    func focus() {
        guard let element else {
            focusOnOtherSpace()
            return
        }

        do {
            try element.performAction(.raise)
            self.application.activate()
        } catch {
            try? self.application.reopen()
        }
    }
    
    static func getFrontWindow() -> Window? {
        guard let frontApplication = Application.getFrontApplication() else {
            return nil
        }
        
        if let focusedWindow = frontApplication.getFocusedWindow() {
            return focusedWindow
        }
        
        if let firstWindow = frontApplication.getFirstWindow() {
            return firstWindow
        }
        
        return nil
    }

    // Switches to the window's space, then raises it once accessibility can see it.
    private func focusOnOtherSpace() {
        guard let space, let cgWindowID else {
            application.activate()
            return
        }

        Spaces.activate(space)

        Task { @MainActor in
            for _ in 0..<Self.spaceActivationAttempts {
                if let element = application.getAXWindows()
                    .first(where: { $0.getWindowID() == cgWindowID }) {
                    self.element = element
                    try? element.performAction(.raise)
                    application.activate()
                    return
                }

                try? await Task.sleep(nanoseconds: Self.spaceActivationPollInterval)
            }

            // The space is now active even if the window could not be raised.
            application.activate()
        }
    }

    private static let titleCache = NSCache<NSNumber, NSString>()

    private static func rememberedTitle(for windowID: CGWindowID) -> String? {
        titleCache.object(forKey: NSNumber(value: windowID)) as String?
    }
}
