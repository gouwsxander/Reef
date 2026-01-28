//
//  PreferencesProfilesView.swift
//  Reef
//
//  Created by Xander Gouws on 28-01-2026.
//

import SwiftUI

struct PreferencesProfilesView: View {
    @State private var profiles: [Profile] = [
        Profile(name: "Default", numberOrder: "rightHanded", bindings: [:])
    ]
    @State private var selectedProfile: Profile.ID?
    
    var body: some View {
        HStack(spacing: 0) {
            // Left panel - Profile list
            VStack(spacing: 0) {
                List(profiles, selection: $selectedProfile) { profile in
                    Text(profile.name)
                        .tag(profile.id)
                }
                
                Divider()
                
                HStack {
                    Button(action: addProfile) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: removeProfile) {
                        Image(systemName: "minus")
                    }
                    .buttonStyle(.borderless)
                    .disabled(profiles.count <= 1 || selectedProfile == nil)
                    
                    Spacer()
                }
                .padding(8)
            }
            .frame(width: 150)
            
            Divider()
            
            // Right panel - Profile details
            if let selectedProfile = selectedProfile,
               let profileIndex = profiles.firstIndex(where: { $0.id == selectedProfile }) {
                ProfileDetailView(profile: $profiles[profileIndex])
            } else {
                Text("Select a profile")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(minHeight: 400)
        .onAppear {
            if selectedProfile == nil {
                selectedProfile = profiles.first?.id
            }
        }
    }
    
    private func addProfile() {
        let newProfile = Profile(name: "New Profile", numberOrder: nil, bindings: [:])
        profiles.append(newProfile)
        selectedProfile = newProfile.id
    }
    
    private func removeProfile() {
        guard let selectedProfile = selectedProfile,
              let index = profiles.firstIndex(where: { $0.id == selectedProfile }) else {
            return
        }
        profiles.remove(at: index)
        self.selectedProfile = profiles.first?.id
    }
}

struct ProfileDetailView: View {
    @Binding var profile: Profile
    @AppStorage("defaultNumberOrder") private var defaultNumberOrder = "rightHanded"
    
    var body: some View {
        Form {
            Section {
                TextField("Profile name:", text: $profile.name)
                
                Picker("Number order:", selection: $profile.numberOrder) {
                    Text("Use default").tag(nil as String?)
                    Text("Right handed (0, 9, ..., 1)").tag("rightHanded" as String?)
                    Text("Left handed (1, ..., 9, 0)").tag("leftHanded" as String?)
                }
                .pickerStyle(.menu)
            }
            
            Section("Application Bindings") {
                ForEach(numbersInOrder, id: \.self) { number in
                    HStack {
                        Text("\(number):")
                            .frame(width: 30, alignment: .leading)
                        
                        if let appURL = profile.bindings[number] {
                            Text(appURL.deletingPathExtension().lastPathComponent)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Button("Remove") {
                                profile.bindings[number] = nil
                            }
                            .buttonStyle(.borderless)
                        } else {
                            Text("Not set")
                                .foregroundStyle(.tertiary)
                            
                            Spacer()
                        }
                        
                        Button("Choose application...") {
                            chooseApplication(for: number)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    private var numbersInOrder: [Int] {
        let effectiveOrder = profile.numberOrder ?? defaultNumberOrder
        
        if effectiveOrder == "leftHanded" {
            return Array(1...9) + [0]
        } else {
            return [0] + Array((1...9).reversed())
        }
    }
    
    private func chooseApplication(for number: Int) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        
        if panel.runModal() == .OK, let url = panel.url {
            profile.bindings[number] = url
        }
    }
}

struct Profile: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var numberOrder: String?  // nil means "use default"
    var bindings: [Int: URL]
}
