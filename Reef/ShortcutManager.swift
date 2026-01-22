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
//    private var isPanelOpen = false
    
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
                print("Activate down")
                
                guard let binding = ConfigManager.config.bindings[number] else {
                    NSSound.beep()
                    return
                }
                
//                self.isPanelOpen = true
                
                if let cycle = CycleManager.cycle {
                    cycle.next()
                    print(cycle.getWindow().title)
                } else {
                    var index = 0
                    
                    // Better to implement Equatable for Application type...
                    if Application.getFrontApplication()?.title == binding.title {
                        index = 1
                    }
                    
                    CycleManager.setCycle(application: binding, index: index)
                    print(CycleManager.cycle?.getWindow().title ?? "Hm")
                }
                
            }
        }
        
        // Global event monitor needed because KeyboardShortcuts doesn't like detecting just a control up... (.control is modifier not regular key?)
        self.globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            
            let controlPressed = event.modifierFlags.contains(.control)
            
            if self?.isControlDown == true && !controlPressed {
                if let cycle = CycleManager.cycle {
                    print("Control released")
                    cycle.getWindow().focus()
                    CycleManager.resetCycle()
                }
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
