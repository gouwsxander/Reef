//
//  ShortcutManager.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//


import KeyboardShortcuts
import Cocoa


let numberKeys: [KeyboardShortcuts.Key] = [
    .zero,
    .one,
    .two,
    .three,
    .four,
    .five,
    .six,
    .seven,
    .eight,
    .nine
]

var config = Config("Default")

extension KeyboardShortcuts.Name {
    
    static let bindShortcuts: [KeyboardShortcuts.Name] = (0...9).map { number in
        Self(
            "bind\(number)",
            default: .init(
                numberKeys[number],
                modifiers: [.control, .option]
            )
        )
    }
    
    static let activateShortcuts: [KeyboardShortcuts.Name] = (0...9).map { number in
        Self(
            "activate\(number)",
            default: .init(
                numberKeys[number],
                modifiers: [.control]
            )
        )
    }
    
}

@MainActor
final class ShortcutManager {
    init() {
        for number in 0...9 {
            KeyboardShortcuts.onKeyUp(for: .bindShortcuts[number]) {
                let focusElement: FocusElement
                if let window = Window.getFrontWindow() {
                    focusElement = window
                } else if let application = Application.getFrontApplication() {
                    focusElement = application
                } else {
                    NSSound.beep()
                    return
                }
                
                config.bind(focusElement, number)
                
                print("Binding \(focusElement.title) to \(number)")
            }
            
            KeyboardShortcuts.onKeyUp(for: .activateShortcuts[number]) {
                guard let focusElement = config.bindings[number] else {
                    NSSound.beep()
                    return
                }
                
                focusElement.focus()
                print("Activating \(focusElement.title)")
            }
        }
    }
}

