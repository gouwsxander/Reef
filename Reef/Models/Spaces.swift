//
//  Spaces.swift
//  Reef
//

import Foundation
import CoreGraphics

typealias CGSSpaceID = UInt64

// An ordered snapshot of the Mission Control spaces and the windows sitting on them.
//
// Accessibility only reports windows on the active space, so discovering the rest
// means going through CoreGraphics. Building the snapshot once per switcher
// invocation keeps that off the per-keystroke path.
struct SpaceSnapshot {
    struct Space: Equatable {
        let id: CGSSpaceID
        let displayIdentifier: String
        // Mission Control's desktop number, or nil for a full-screen space.
        let number: Int?
        let isCurrent: Bool
    }

    let spaces: [Space]
    let spaceIDsByWindow: [CGWindowID: CGSSpaceID]

    func space(for windowID: CGWindowID) -> Space? {
        guard let spaceID = spaceIDsByWindow[windowID] else { return nil }
        return spaces.first { $0.id == spaceID }
    }

    var hasMultipleSpaces: Bool {
        spaces.count > 1
    }
}

enum Spaces {
    // Windows smaller than this are toolbars, shadows and other helper surfaces that
    // CoreGraphics reports alongside real windows. Accessibility filters them by role;
    // for windows on other spaces there is no role to inspect.
    private static let minimumWindowSize: CGFloat = 150

    static func snapshot() -> SpaceSnapshot {
        let connection = CGSMainConnectionID()
        let displays = CGSCopyManagedDisplaySpaces(connection) as? [[String: Any]] ?? []
        let spaces = parseSpaces(displays: displays) { CGSSpaceGetType(connection, $0) == userSpaceType }

        var spaceIDsByWindow: [CGWindowID: CGSSpaceID] = [:]
        for space in spaces {
            for windowID in windowIDs(on: space.id, connection: connection) {
                spaceIDsByWindow[windowID] = space.id
            }
        }

        return SpaceSnapshot(spaces: spaces, spaceIDsByWindow: spaceIDsByWindow)
    }

    // Brings the given space to the front. The change is animated, so a window on it
    // only becomes reachable through accessibility a short while later.
    static func activate(_ space: SpaceSnapshot.Space) {
        CGSManagedDisplaySetCurrentSpace(
            CGSMainConnectionID(),
            space.displayIdentifier as CFString,
            space.id
        )
    }

    // CoreGraphics window IDs that look like real, switchable windows of a process.
    static func switchableWindowIDs(ofProcess pid: pid_t) -> [CGWindowID] {
        let entries = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]] ?? []

        return entries.compactMap { entry in
            guard let windowID = entry[kCGWindowNumber as String] as? CGWindowID,
                  entry[kCGWindowOwnerPID as String] as? pid_t == pid,
                  entry[kCGWindowLayer as String] as? Int == 0,
                  let boundsValue = entry[kCGWindowBounds as String] as? [String: Any],
                  let bounds = CGRect(dictionaryRepresentation: boundsValue as CFDictionary),
                  bounds.width >= minimumWindowSize,
                  bounds.height >= minimumWindowSize else {
                return nil
            }

            return windowID
        }
    }

    // Splits the display dictionaries CoreGraphics returns into ordered spaces.
    // Kept separate from the private API so it can be tested directly.
    static func parseSpaces(
        displays: [[String: Any]],
        isUserSpace: (CGSSpaceID) -> Bool
    ) -> [SpaceSnapshot.Space] {
        var spaces: [SpaceSnapshot.Space] = []
        var number = 0

        for display in displays {
            let displayIdentifier = display[Key.displayIdentifier] as? String ?? ""
            let currentSpaceID = (display[Key.currentSpace] as? [String: Any])?[Key.managedSpaceID] as? CGSSpaceID

            for entry in display[Key.spaces] as? [[String: Any]] ?? [] {
                guard let id = entry[Key.managedSpaceID] as? CGSSpaceID else { continue }

                // Full-screen spaces are switchable but carry no desktop number.
                let isUser = isUserSpace(id)
                if isUser { number += 1 }

                spaces.append(
                    SpaceSnapshot.Space(
                        id: id,
                        displayIdentifier: displayIdentifier,
                        number: isUser ? number : nil,
                        isCurrent: id == currentSpaceID
                    )
                )
            }
        }

        return spaces
    }

    private static func windowIDs(on space: CGSSpaceID, connection: Int32) -> [CGWindowID] {
        var setTags: UInt64 = 0
        var clearTags: UInt64 = 0
        let windows = CGSCopyWindowsWithOptionsAndTags(
            connection, 0, [space] as CFArray, 0, &setTags, &clearTags
        )

        return windows as? [CGWindowID] ?? []
    }

    private static let userSpaceType: Int32 = 0

    private enum Key {
        static let displayIdentifier = "Display Identifier"
        static let currentSpace = "Current Space"
        static let managedSpaceID = "ManagedSpaceID"
        static let spaces = "Spaces"
    }
}


// Private CoreGraphics window server API. Reef already relies on _AXUIElementGetWindow;
// there is no public way to see or activate a space.
@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> Int32

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ connection: Int32) -> CFArray

@_silgen_name("CGSCopyWindowsWithOptionsAndTags")
func CGSCopyWindowsWithOptionsAndTags(
    _ connection: Int32,
    _ owner: UInt32,
    _ spaces: CFArray,
    _ options: UInt32,
    _ setTags: UnsafeMutablePointer<UInt64>,
    _ clearTags: UnsafeMutablePointer<UInt64>
) -> CFArray

@_silgen_name("CGSSpaceGetType")
func CGSSpaceGetType(_ connection: Int32, _ space: CGSSpaceID) -> Int32

@_silgen_name("CGSManagedDisplaySetCurrentSpace")
func CGSManagedDisplaySetCurrentSpace(_ connection: Int32, _ display: CFString, _ space: CGSSpaceID)


// Cross-space switching changes long-standing behaviour and moves the user between
// desktops, so it stays opt-in.
enum CrossSpaceSwitching {
    static let defaultsKey = "includeWindowsFromOtherSpaces"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: defaultsKey)
    }
}
