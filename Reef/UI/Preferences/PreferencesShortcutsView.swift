//
//  PreferencesShortcutsView.swift
//  Reef
//
//  Created by Xander Gouws on 26-01-2026.
//

import SwiftUI
import KeyboardShortcuts

struct PreferencesShortcutsView: View {
    @AppStorage("bindControl") private var bindControl = true
    @AppStorage("bindOption") private var bindOption = false
    @AppStorage("bindCommand") private var bindCommand = false
    @AppStorage("bindShift") private var bindShift = false
    
    @AppStorage("activateControl") private var activateControl = true
    @AppStorage("activateOption") private var activateOption = false
    @AppStorage("activateCommand") private var activateCommand = false
    @AppStorage("activateShift") private var activateShift = false
    
    var body: some View {
        Form {
            Section {
                Grid(alignment: .leading, horizontalSpacing: 20, verticalSpacing: 12) {
                    // Header row
                    GridRow {
                        Text("")
                        Text("⌃")
                        Text("⌥")
                        Text("⌘")
                        Text("⇧")
                    }
                    .fontWeight(.medium)
                    
                    Divider()
                    
                    // Bind modifiers row
                    GridRow {
                        Text("Bind modifiers")
                        Toggle("", isOn: $bindControl).toggleStyle(.checkbox)
                        Toggle("", isOn: $bindOption).toggleStyle(.checkbox)
                        Toggle("", isOn: $bindCommand).toggleStyle(.checkbox)
                        Toggle("", isOn: $bindShift).toggleStyle(.checkbox)
                    }
                    
                    // Activate modifiers row
                    GridRow {
                        Text("Activate modifiers")
                        Toggle("", isOn: $activateControl).toggleStyle(.checkbox)
                        Toggle("", isOn: $activateOption).toggleStyle(.checkbox)
                        Toggle("", isOn: $activateCommand).toggleStyle(.checkbox)
                        Toggle("", isOn: $activateShift).toggleStyle(.checkbox)
                    }
                }
                .padding(.vertical, 8)
            } footer: {
                Text("⌃ Control  •  ⌥ Option  •  ⌘ Command  •  ⇧ Shift")
            }
        }
        .formStyle(.grouped)
        .frame(height: 200)
    }
}

#Preview {
    PreferencesShortcutsView()
}
