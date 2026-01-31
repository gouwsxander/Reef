//
//  PreferencesGeneralView.swift
//  Reef
//
//  Created by Xander Gouws on 26-01-2026.
//

import SwiftUI

struct PreferencesGeneralView: View {
    @AppStorage("launchOnLogin") private var launchOnLogin = false
    @AppStorage("hideMenubarIcon") private var hideMenubarIcon = false
    @AppStorage("appearance") private var appearance = "system"
    @AppStorage("defaultNumberOrder") private var defaultNumberOrder = "rightHanded"
    
    var body: some View {
        Form {
            Section {
                Toggle("Launch Reef at login", isOn: $launchOnLogin)
                Toggle("Hide menubar icon", isOn: $hideMenubarIcon)
            }
            
            Section {
                Picker("Default number order:", selection: $defaultNumberOrder) {
                    Text("Right handed (0, 9, ..., 1)").tag("rightHanded")
                    Text("Left handed (1, ..., 9, 0)").tag("leftHanded")
                }
                .pickerStyle(.menu)
            } footer: {
                Text("Number order sets the order in which numbers are displayed in the menubar")
            }
        }
        .formStyle(.grouped)
        .frame(height: 190)
    }
}

#Preview {
    PreferencesGeneralView()
}
