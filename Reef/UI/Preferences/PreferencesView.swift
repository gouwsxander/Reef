//
//  PreferencesView.swift
//  Reef
//
//  Created by Xander Gouws on 26-01-2026.
//

import SwiftUI

struct PreferencesView: View {
    var body: some View {
        TabView {
            PreferencesGeneralView()
                .tabItem { Label("General", systemImage: "gear")}
            
            PreferencesProfilesView()
                .tabItem { Label("Profiles", systemImage: "person.crop.rectangle.stack") }
            
            PreferencesShortcutsView()
                .tabItem { Label("Shortcuts", systemImage: "command") }
        }
        .frame(width: 600)
    }
}

#Preview {
    PreferencesView()
}
