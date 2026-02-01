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
    @AppStorage("bindEnabled") var bindEnabled = true {
        didSet { updateShortcuts() }
    }
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
    
    @AppStorage("activateEnabled") var activateEnabled = true {
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
    
    @AppStorage("profileEnabled") var profileEnabled = true {
        didSet { updateShortcuts() }
    }
    @AppStorage("profileControl") var profileControl = true {
        didSet { updateShortcuts() }
    }
    @AppStorage("profileOption") var profileOption = true {
        didSet { updateShortcuts() }
    }
    @AppStorage("profileCommand") var profileCommand = false {
        didSet { updateShortcuts() }
    }
    @AppStorage("profileShift") var profileShift = true {
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
    
    var profileModifiers: NSEvent.ModifierFlags {
        var modifiers: NSEvent.ModifierFlags = []
        if profileControl { modifiers.insert(.control) }
        if profileOption { modifiers.insert(.option) }
        if profileCommand { modifiers.insert(.command) }
        if profileShift { modifiers.insert(.shift) }
        return modifiers
    }
    
    var activateEventModifiers: EventModifiers {
        var modifiers: EventModifiers = []
        if activateControl { modifiers.insert(.control) }
        if activateOption { modifiers.insert(.option) }
        if activateCommand { modifiers.insert(.command) }
        if activateShift { modifiers.insert(.shift) }
        return modifiers
    }
    
    var profileEventModifiers: EventModifiers {
        var modifiers: EventModifiers = []
        if profileControl { modifiers.insert(.control) }
        if profileOption { modifiers.insert(.option) }
        if profileCommand { modifiers.insert(.command) }
        if profileShift { modifiers.insert(.shift) }
        return modifiers
    }
    
    var profileModifierSymbols: String {
        var symbols = ""
        if profileControl  { symbols += "⌃ " }
        if profileOption   { symbols += "⌥ " }
        if profileShift    { symbols += "⇧ " }
        if profileCommand  { symbols += "⌘ " }
        return symbols
    }
    
    private func updateShortcuts() {
        let bindMods = bindModifiers
        let activateMods = activateModifiers
        let profileMods = profileModifiers

        for number in 0...9 {
            KeyboardShortcuts.setShortcut(
                bindEnabled ? .init(numberKeys[number], modifiers: bindMods) : nil,
                for: .bindShortcuts[number]
            )

            KeyboardShortcuts.setShortcut(
                activateEnabled ? .init(numberKeys[number], modifiers: activateMods) : nil,
                for: .activateShortcuts[number]
            )

            KeyboardShortcuts.setShortcut(
                profileEnabled ? .init(numberKeys[number], modifiers: profileMods) : nil,
                for: .profileShortcuts[number]
            )
        }
    }
}
