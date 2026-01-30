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
}

@MainActor
final class ShortcutController {
    private let cycleController: CyclePanelController
    private let bindings: Bindings
    
    init(_ cycleController: CyclePanelController, _ bindings: Bindings) {
        self.cycleController = cycleController
        self.bindings = bindings
        
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
        }
    }
    
    private func handleBind(number: Int) {
        guard let application = Application.getFrontApplication() else {
            NSSound.beep()
            return
        }
        
        bindings.bind(application, number)
        
        print("Bound \(application.title) to \(number)")
    }
    
    private func handleActivate(number: Int) {
        guard let binding = bindings[number] else {
            NSSound.beep()
            return
        }
        
        // If panel is already visible, cycle to next window
        if cycleController.panel.isVisible {
            cycleController.cycleNext()
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
}
