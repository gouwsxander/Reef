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
                guard let application = Application.getFrontApplication() else {
                    NSSound.beep()
                    return
                }
                
                guard ConfigManager.config.bind(application, number) else {
                    NSSound.beep()
                    return
                }
                
                print("Binding \(application.title) to \(number)")
            }
            
            KeyboardShortcuts.onKeyUp(for: .activateShortcuts[number]) {
                guard let binding = ConfigManager.config.bindings[number] else {
                    NSSound.beep()
                    return
                }
                
                binding.focus()
                print("Activating \(binding.title)")
                
                let application = Application.getFrontApplication()
                if let wl = application?.getAXWindows() {
                    for w in wl {
                        print(w.getWindowID())
                    }
                }
            }
        }
    }
}

