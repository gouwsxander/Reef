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
    
    static let ctrlKey: KeyboardShortcuts.Name = Self("control", default: .init(.control))
}


@MainActor
final class ShortcutManager {
    private var globalEventMonitor: Any?
    private var isControlDown = false
    private var isPanelOpen = false
    
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
            
            KeyboardShortcuts.onKeyDown(for: .activateShortcuts[number]) {
                self.isPanelOpen = true
                print("Activate down")
//                guard let binding = ConfigManager.config.bindings[number] else {
//                    NSSound.beep()
//                    return
//                }
//
//                binding.focus()
//                print("Activating \(binding.title)")
//
//                let wl = binding.getAXWindows()
//                for w in wl {
//                    let window = Window(w, binding)
//                    print(window.title)
//                }
            }
        }
        
        // Global event monitor needed because KeyboardShortcuts doesn't like detecting just a control up... (.control is modifier not regular key?)
        self.globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            
            let controlPressed = event.modifierFlags.contains(.control)
            
            if self?.isControlDown == true && !controlPressed && self?.isPanelOpen == true {
                print("Control released")
                self?.isPanelOpen = false
            }
            
            self?.isControlDown = controlPressed
        }
    }
    
    deinit {
        if let globalEventMonitor {
            NSEvent.removeMonitor(globalEventMonitor)
        }
    }
}
