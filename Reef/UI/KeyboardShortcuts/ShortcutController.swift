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
}

@MainActor
final class ShortcutController {
    private let cycleController: CyclePanelController
    private let profileManager: ProfileManager
    
    init(_ cycleController: CyclePanelController, _ profileManager: ProfileManager) {
        self.cycleController = cycleController
        self.profileManager = profileManager
        
        setupShortcuts()
    }
    
    private func setupShortcuts() {
        for number in 0...9 {
            KeyboardShortcuts.onKeyUp(for: .bindShortcuts[number]) {
                self.handleBind(number: number)
            }
            
            KeyboardShortcuts.onKeyDown(for: .activateShortcuts[number]) {
                self.handleActivate(number: number)
            }
            
            KeyboardShortcuts.onKeyDown(for: .profileShortcuts[number]) {
                self.handleProfile(number: number)
            }
        }
    }
    
    private func handleBind(number: Int) {
        guard let application = Application.getFrontApplication() else {
            NSSound.beep()
            return
        }
        
        profileManager.currentProfile.bind(application, number)
        
        print("Bound \(application.title) to \(number)")
    }
    
    private func handleActivate(number: Int) {
        guard let binding = profileManager.currentProfile[number] else {
            NSSound.beep()
            return
        }
        
        // If panel is already visible, cycle to next window
        if cycleController.panel.isVisible {
            cycleController.cycleNext()
            return
        }

        // If the bound application was quit/terminated, relaunch it and do not show the cycle panel.
        if binding.runningApplication.isTerminated {
            binding.focus()
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
        guard let profile = profileManager.profilesByNumber[number] else {
            NSSound.beep()
            return
        }
        
        profileManager.switchProfile(profile)
    }
}
