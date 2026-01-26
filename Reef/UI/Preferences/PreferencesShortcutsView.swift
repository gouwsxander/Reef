//
//  PreferencesShortcutsView.swift
//  Reef
//
//  Created by Xander Gouws on 26-01-2026.
//

import SwiftUI
import KeyboardShortcuts

struct PreferencesShortcutsView: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Test", name: .activateShortcuts[0])
            
            KeyboardShortcuts.Recorder("Test", name: .activateShortcuts[1])
            
            KeyboardShortcuts.Recorder("Test", name: .activateShortcuts[2])
        }
        .padding()
    }
}

#Preview {
    PreferencesShortcutsView()
}
