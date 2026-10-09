//
//  ShortcutController.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import KeyboardShortcuts
import Cocoa

let numberKeys: [KeyboardShortcuts.Key] = [
    .zero, .one, .two, .three, .four,
    .five, .six, .seven, .eight, .nine
]

// Numeric-keypad equivalents of `numberKeys`. Numpad keys have distinct virtual
// key codes from the main row (e.g. kVK_ANSI_Keypad0 != kVK_ANSI_0), so they
// must be registered as separate global hotkeys to also fire from the numpad.
let keypadKeys: [KeyboardShortcuts.Key] = [
    .keypad0, .keypad1, .keypad2, .keypad3, .keypad4,
    .keypad5, .keypad6, .keypad7, .keypad8, .keypad9
]

extension KeyboardShortcuts.Name {
    static let bindShortcuts: [KeyboardShortcuts.Name] = (0...9).map { number in
        Self("bind\(number)")
    }
    
    static let activateShortcuts: [KeyboardShortcuts.Name] = (0...9).map { number in
        Self("activate\(number)")
    }
    
    static let profileShortcuts: [KeyboardShortcuts.Name] = (0...9).map { number in
        Self("profile\(number)")
    }

    // Numeric-keypad counterparts registered alongside the main-row shortcuts.
    static let bindKeypadShortcuts: [KeyboardShortcuts.Name] = (0...9).map { number in
        Self("bindKeypad\(number)")
    }

    static let activateKeypadShortcuts: [KeyboardShortcuts.Name] = (0...9).map { number in
        Self("activateKeypad\(number)")
    }

    static let profileKeypadShortcuts: [KeyboardShortcuts.Name] = (0...9).map { number in
        Self("profileKeypad\(number)")
    }
}

@MainActor
final class ShortcutController {
    private let cycleController: CyclePanelController
    private let profileManager: ProfileManager
    private let feedbackController: FeedbackPanelController
    private let modifierManager: ModifierManager
    
    init(
        _ cycleController: CyclePanelController,
        _ profileManager: ProfileManager,
        _ feedbackController: FeedbackPanelController,
        _ modifierManager: ModifierManager
    ) {
        self.cycleController = cycleController
        self.profileManager = profileManager
        self.feedbackController = feedbackController
        self.modifierManager = modifierManager
        
        setupShortcuts()
    }
    
    private func setupShortcuts() {
        for number in 0...9 {
            // Register both the main-row and numeric-keypad shortcut for each
            // number so either physical key triggers the same action.
            for name in [KeyboardShortcuts.Name.bindShortcuts[number], .bindKeypadShortcuts[number]] {
                KeyboardShortcuts.onKeyUp(for: name) {
                    self.handleBind(number: number)
                }
            }

            for name in [KeyboardShortcuts.Name.activateShortcuts[number], .activateKeypadShortcuts[number]] {
                KeyboardShortcuts.onKeyDown(for: name) {
                    self.handleActivate(number: number)
                }
            }

            for name in [KeyboardShortcuts.Name.profileShortcuts[number], .profileKeypadShortcuts[number]] {
                KeyboardShortcuts.onKeyDown(for: name) {
                    self.handleProfile(number: number)
                }
            }
        }
    }
    
    private func handleBind(number: Int) {
        guard let application = Application.getFrontApplication() else {
            NSSound.beep()
            return
        }

        guard let bundleIdentifier = application.bundleIdentifier else {
            NSSound.beep()
            return
        }

        profileManager.bind(bundleIdentifier: bundleIdentifier, to: number)
        guard profileManager.bundleIdentifier(for: number) == bundleIdentifier else {
            NSSound.beep()
            return
        }
        let shortcut = modifierManager.activateEnabled
            ? modifierManager.activateModifierSymbols + String(number)
            : "slot \(number) (switching disabled)"
        feedbackController.show(
            "Assigned \(shortcut) to \(application.title)",
            icon: application.icon
        )
    }
    
    private func handleActivate(number: Int) {
        guard let binding = profileManager.application(for: number) else {
            NSSound.beep()
            return
        }
        
        // If panel is already visible, cycle if same app; otherwise switch to the newly requested app.
        if cycleController.panel.isVisible {
            if cycleController.isShowingSwitcher(for: binding) {
                cycleController.cycleNext()
            } else {
                cycleController.showSwitcher(for: binding)
            }
            
            return
        }

        // Determine starting index
        var startIndex = 0
        if let frontApp = Application.getFrontApplication(),
           frontApp.title == binding.title {
            // Already on this app, start at second window
            startIndex = 1
        }
        
        cycleController.showSwitcher(for: binding, startIndex: startIndex)
    }
    
    func handleProfile(number: Int) {
        guard let profileID = profileManager.profileID(forNumber: number) else {
            NSSound.beep()
            return
        }

        let previousProfileID = profileManager.currentProfileID
        profileManager.switchProfile(id: profileID)

        if previousProfileID != profileID,
           let profileName = profileManager.currentProfile?.name {
            feedbackController.show("Switched to \(profileName) profile")
        }
    }
}
