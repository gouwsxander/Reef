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
                        Toggle("Activate modifiers", isOn: $modifierManager.activateEnabled).toggleStyle(.checkbox)
                        Group {
                            Toggle("", isOn: $modifierManager.activateControl).toggleStyle(.checkbox)
                            Toggle("", isOn: $modifierManager.activateOption).toggleStyle(.checkbox)
                            Toggle("", isOn: $modifierManager.activateShift).toggleStyle(.checkbox)
                            Toggle("", isOn: $modifierManager.activateCommand).toggleStyle(.checkbox)
                        }
                        .disabled(!modifierManager.activateEnabled)
                    }
                    
                    // Profile modifiers row
                    GridRow {
                        Toggle("Profile modifiers", isOn: $modifierManager.profileEnabled).toggleStyle(.checkbox)
                        Group {
                            Toggle("", isOn: $modifierManager.profileControl).toggleStyle(.checkbox)
                            Toggle("", isOn: $modifierManager.profileOption).toggleStyle(.checkbox)
                            Toggle("", isOn: $modifierManager.profileShift).toggleStyle(.checkbox)
                            Toggle("", isOn: $modifierManager.profileCommand).toggleStyle(.checkbox)
                        }
                        .disabled(!modifierManager.profileEnabled)
                    }

                    // Bind modifiers row
                    GridRow {
                        Toggle("Bind modifiers", isOn: $modifierManager.bindEnabled).toggleStyle(.checkbox)
                        Group {
                            Toggle("", isOn: $modifierManager.bindControl).toggleStyle(.checkbox)
                            Toggle("", isOn: $modifierManager.bindOption).toggleStyle(.checkbox)
                            Toggle("", isOn: $modifierManager.bindShift).toggleStyle(.checkbox)
                            Toggle("", isOn: $modifierManager.bindCommand).toggleStyle(.checkbox)
                        }
                        .disabled(!modifierManager.bindEnabled)
                        
                    }
                }
                .padding(.vertical, 8)
            } footer: {
                Text("⌃ Control  •  ⌥ Option  •  ⇧ Shift  •  ⌘ Command")
            }
        }
        .formStyle(.grouped)
        .frame(height: 225)
    }
}

#Preview {
    PreferencesShortcutsView()
}
