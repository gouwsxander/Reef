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
    
    var body: some View {
        // Profiles
        ForEach(profiles) { profile in
            Button(profile.name) {
                profileManager.switchProfile(profile)
            }
        }
        
        Divider()
        
        // Bindings
        ForEach(Array(stride(from: 0, through: 9, by: 1)), id: \.self) { i in
            let number = (10 - i) % 10
            if let binding = profileManager.currentProfile[number] {
                Button("\(number) | \(binding.title)") {
                    binding.focus()
                }
//                .keyboardShortcut(KeyEquivalent(Character("\(number)")), modifiers: [])
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
