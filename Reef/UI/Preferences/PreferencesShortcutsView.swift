//
//  PreferencesShortcutsView.swift
//  Reef
//
//  Created by Xander Gouws on 26-01-2026.
//

import SwiftUI
import KeyboardShortcuts

struct PreferencesShortcutsView: View {
    @StateObject private var modifierManager: ModifierManager = {
        if let manager = AppDelegate.modifierManager {
            return manager
        }
        return ModifierManager()
    }()
    
    var body: some View {
        Form {
            Section {
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                    // Header row
                    GridRow {
                        Text("")
                        Text("⌃")
                        Text("⌥")
                        Text("⇧")
                        Text("⌘")
                    }
                    .fontWeight(.medium)
                    
                    Divider()
                    
                    // Activate modifiers row
                    GridRow {
                        Text("Activate modifiers")
                        Toggle("", isOn: $modifierManager.activateControl).toggleStyle(.checkbox)
                        Toggle("", isOn: $modifierManager.activateOption).toggleStyle(.checkbox)
                        Toggle("", isOn: $modifierManager.activateShift).toggleStyle(.checkbox)
                        Toggle("", isOn: $modifierManager.activateCommand).toggleStyle(.checkbox)
                    }
                    
                    // Profile modifiers row
                    GridRow {
                        Text("Profile modifiers")
                        Toggle("", isOn: $modifierManager.profileControl).toggleStyle(.checkbox)
                        Toggle("", isOn: $modifierManager.profileOption).toggleStyle(.checkbox)
                        Toggle("", isOn: $modifierManager.profileShift).toggleStyle(.checkbox)
                        Toggle("", isOn: $modifierManager.profileCommand).toggleStyle(.checkbox)
                    }

                    // Bind modifiers row
                    GridRow {
                        Text("Bind modifiers")
                        Toggle("", isOn: $modifierManager.bindControl).toggleStyle(.checkbox)
                        Toggle("", isOn: $modifierManager.bindOption).toggleStyle(.checkbox)
                        Toggle("", isOn: $modifierManager.bindShift).toggleStyle(.checkbox)
                        Toggle("", isOn: $modifierManager.bindCommand).toggleStyle(.checkbox)
                    }
                }
                .padding(.vertical, 8)
            } footer: {
                Text("⌃ Control  •  ⌥ Option  •  ⇧ Shift  •  ⌘ Command")
            }
        }
        .formStyle(.grouped)
        .frame(height: 195)
    }
}

#Preview {
    PreferencesShortcutsView()
}
