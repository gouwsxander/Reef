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

var frontApplication: Application?
var boundWindow: Window?

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
               
//                print(Window.getFrontWindow() as Any)
//                print(Window.getFrontWindow()?.getBestTitle() ?? "Nope")
               
//                frontApplication = Application.getFrontApplication()
//                print(frontApplication?.getFocusedWindow()?.getBestTitle() ?? "")
//                print(frontApplication?.getFirstWindow()?.getBestTitle() ?? "")
                
//                boundApplication = Application.getFrontApplication()
                
                boundWindow = Window.getFrontWindow()
                
                print("Binding to \(number)")

                
            }
            
            KeyboardShortcuts.onKeyUp(for: .activateShortcuts[number]) {
                print("Activating \(number)")
                
//                try? frontApplication?.reopen()
                boundWindow?.focus()
            }
        }
        
    }
}

