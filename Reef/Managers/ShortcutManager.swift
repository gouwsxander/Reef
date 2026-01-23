//
//  ShortcutManager.swift
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
        Self("bind\(number)", default: .init(numberKeys[number], modifiers: [.control, .option]))
    }
    
    static let activateShortcuts: [KeyboardShortcuts.Name] = (0...9).map { number in
        Self("activate\(number)", default: .init(numberKeys[number], modifiers: [.control]))
    }
}

@MainActor
final class ShortcutManager {
    private let switcher: WindowSwitcherController
    
    init(switcher: WindowSwitcherController) {
        self.switcher = switcher
        setupShortcuts()
    }
    
    private func setupShortcuts() {
        // Ctrl + Alt + [Number] - Bind application
        for number in 0...9 {
            KeyboardShortcuts.onKeyUp(for: .bindShortcuts[number]) {
                self.handleBind(number: number)
            }
            
            KeyboardShortcuts.onKeyDown(for: .activateShortcuts[number]) {
                self.handleActivate(number: number)
            }
        }
    }
    
    private func handleBind(number: Int) {
        guard let application = Application.getFrontApplication() else {
            NSSound.beep()
            return
        }
        
        guard ConfigManager.config.bind(application, number) else {
            NSSound.beep()
            return
        }
        
        print("✓ Bound \(application.title) to \(number)")
    }
    
    private func handleActivate(number: Int) {
        guard let binding = ConfigManager.config.bindings[number] else {
            NSSound.beep()
            return
        }
        
        // If panel is already visible, cycle to next window
        if switcher.panel.isVisible {
            switcher.cycleNext()
            return
        }
        
        // Determine starting index
        var startIndex = 0
        if let frontApp = Application.getFrontApplication(),
           frontApp.title == binding.title {
            // Already on this app, start at second window
            startIndex = 1
        }
        
        switcher.showSwitcher(for: binding, startIndex: startIndex)
    }
}
