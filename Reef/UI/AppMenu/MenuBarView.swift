//
//  MenuBarView.swift
//  Reef
//
//  Created by Xander Gouws on 28-01-2026.
//

import SwiftUI
import SwiftData

struct MenuBarView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @Query(sort: \Bindings.createdDate, order: .forward) var profiles: [Bindings]
    
    @Environment(\.openSettings) private var openSettings
    
    @StateObject private var modifierManager: ModifierManager = {
        if let manager = AppDelegate.modifierManager {
            return manager
        }
        return ModifierManager()
    }()

    
    var body: some View {
        // Profiles
        ForEach(profiles) { profile in
            if modifierManager.profileEnabled, let profileNumber = profile.profileNumber {
                Button(profile.name) {
                    profileManager.switchProfile(profile)
                }
                .keyboardShortcut(KeyEquivalent(Character("\(profileNumber)")), modifiers: modifierManager.profileEventModifiers)
            } else {
                Button(profile.name) {
                    profileManager.switchProfile(profile)
                }
            }
        }
        
        Divider()
        
        // Bindings
        ForEach(Array(stride(from: 0, through: 9, by: 1)), id: \.self) { i in
            let number = (10 - i) % 10
            if let binding = profileManager.currentProfile[number] {
                if modifierManager.activateEnabled {
                    Button("\(binding.title)") {
                        binding.focus()
                    }
                    .keyboardShortcut(KeyEquivalent(Character("\(number)")), modifiers: modifierManager.activateEventModifiers)
                } else {
                    Button("\(binding.title)") {
                        binding.focus()
                    }
                }
            }
        }
        
        Divider()
        
        Button("Preferences...") {
            openSettings()
        }
        
        Button("About Reef") {
            NSApp.orderFrontStandardAboutPanel()
        }
        
        Button("Quit") {
            NSApp.terminate(nil)
        }
    }
}
