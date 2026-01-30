//
//  ModifierManager.swift
//  Reef
//
//  Created by Xander Gouws on 30-01-2026.
//

import SwiftUI
import KeyboardShortcuts

@MainActor
final class ModifierManager: ObservableObject {
    @AppStorage("bindControl") var bindControl = true {
        didSet { updateShortcuts() }
    }
    @AppStorage("bindOption") var bindOption = false {
        didSet { updateShortcuts() }
    }
    @AppStorage("bindCommand") var bindCommand = false {
        didSet { updateShortcuts() }
    }
    @AppStorage("bindShift") var bindShift = false {
        didSet { updateShortcuts() }
    }
    
    @AppStorage("activateControl") var activateControl = true {
        didSet { updateShortcuts() }
    }
    @AppStorage("activateOption") var activateOption = false {
        didSet { updateShortcuts() }
    }
    @AppStorage("activateCommand") var activateCommand = false {
        didSet { updateShortcuts() }
    }
    @AppStorage("activateShift") var activateShift = false {
        didSet { updateShortcuts() }
    }
    
    init() {
        // Initialize shortcuts with saved modifiers on first launch
        updateShortcuts()
    }
    
    var bindModifiers: NSEvent.ModifierFlags {
        var modifiers: NSEvent.ModifierFlags = []
        if bindControl { modifiers.insert(.control) }
        if bindOption { modifiers.insert(.option) }
        if bindCommand { modifiers.insert(.command) }
        if bindShift { modifiers.insert(.shift) }
        return modifiers
    }
    
    var activateModifiers: NSEvent.ModifierFlags {
        var modifiers: NSEvent.ModifierFlags = []
        if activateControl { modifiers.insert(.control) }
        if activateOption { modifiers.insert(.option) }
        if activateCommand { modifiers.insert(.command) }
        if activateShift { modifiers.insert(.shift) }
        return modifiers
    }
    
    private func updateShortcuts() {
        let bindMods = bindModifiers
        let activateMods = activateModifiers
        
        for number in 0...9 {
            // Update bind shortcuts
            KeyboardShortcuts.setShortcut(
                .init(numberKeys[number], modifiers: bindMods),
                for: .bindShortcuts[number]
            )
            
            // Update activate shortcuts
            KeyboardShortcuts.setShortcut(
                .init(numberKeys[number], modifiers: activateMods),
                for: .activateShortcuts[number]
            )
        }
    }
}
