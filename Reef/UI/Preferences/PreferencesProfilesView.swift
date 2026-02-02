//
//  PreferencesProfilesView.swift
//  Reef
//
//  Created by Xander Gouws on 28-01-2026.
//

import SwiftUI
import SwiftData

struct PreferencesProfilesView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @StateObject private var modifierManager: ModifierManager = {
        if let manager = AppDelegate.modifierManager {
            return manager
        }
        return ModifierManager()
    }()
    @Query(sort: \Bindings.createdDate, order: .forward) var profiles: [Bindings]
    @State private var selectedProfileID: PersistentIdentifier?
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                List(profiles, id: \.persistentModelID, selection: $selectedProfileID) { profile in
                    HStack {
                        Text(profile.name)

                        if let number = profile.profileNumber {
                            Spacer()
                            
                            Text("\(modifierManager.profileModifierSymbols)\(number)")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                                .frame(minWidth: 40, alignment: .trailing)
                        }
                    }
                    .tag(profile.persistentModelID)
                }
                .onChange(of: selectedProfileID) { _, newID in
                    if let newID = newID,
                       let profile = profiles.first(where: { $0.persistentModelID == newID }) {
                        profileManager.switchProfile(profile)
                    }
                }
                
                Divider()
                
                HStack {
                    Button(action: addProfile) {
                        Image(systemName: "plus")
                            .frame(width: 20, height:20)
                    }
                    .buttonStyle(.borderless)
                    
                    Button(action: removeProfile) {
                        Image(systemName: "minus")
                            .frame(width: 20, height:20)
                    }
                    .buttonStyle(.borderless)
                    .disabled(profiles.count <= 1 || selectedProfileID == nil)
                    
                    Spacer()
                }
                .padding(8)
            }
            .frame(width: 200)
            
            Divider()
            
            if let selectedProfileID = selectedProfileID,
               let selectedProfile = profiles.first(where: { $0.persistentModelID == selectedProfileID }) {
                ProfileDetailView(
                    profile: selectedProfile,
                    profileManager: profileManager,
                    modifierManager: modifierManager
                )
            } else {
                Text("Select a profile")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: 575)
        .onAppear {
            if selectedProfileID == nil {
                selectedProfileID = profileManager.currentProfile.persistentModelID
            }
        }
    }
    
    private func addProfile() {
        let newProfile = profileManager.createProfile(name: "New Profile")
        selectedProfileID = newProfile.persistentModelID
    }
    
    private func removeProfile() {
        guard profiles.count > 1,
              let selectedID = selectedProfileID,
              let selectedIndex = profiles.firstIndex(where: { $0.persistentModelID == selectedID }) else {
            return
        }
        
        let selectedProfile = profiles[selectedIndex]
        
        // Pick the next profile below, or fall back to the one above
        let nextIndex = selectedIndex + 1 < profiles.count ? selectedIndex + 1 : selectedIndex - 1
        let nextProfile = profiles[nextIndex]
        
        if selectedProfile.persistentModelID == profileManager.currentProfile.persistentModelID {
            profileManager.switchProfile(nextProfile)
        }
        
        profileManager.deleteProfile(selectedProfile)
        selectedProfileID = nextProfile.persistentModelID
    }
}

struct ProfileDetailView: View {
    @ObservedObject var profile: Bindings
    @ObservedObject var profileManager: ProfileManager
    @ObservedObject var modifierManager: ModifierManager
    @AppStorage("defaultNumberOrder") private var defaultNumberOrder = "rightHanded"
    
    
    var body: some View {
        Form {
            Section {
                TextField("Profile name:", text: $profile.name)
                    .onChange(of: profile.name) { _, _ in
                        try? profileManager.modelContext.save()
                    }
                
                Picker("Number order:", selection: $profile.numberOrder) {
                    Text("Use default").tag(nil as String?)
                    Text("Right handed (0, 9, ..., 1)").tag("rightHanded" as String?)
                    Text("Left handed (1, ..., 9, 0)").tag("leftHanded" as String?)
                }
                .pickerStyle(.menu)
                .onChange(of: profile.numberOrder) { _, _ in
                    try? profileManager.modelContext.save()
                }
                
                Picker("Profile number:", selection: $profile.profileNumber) {
                    Text("Unnumbered").tag(nil as Int?)
                    
                    Divider()
                    
                    let numberOrder = profile.numberOrder ?? defaultNumberOrder
                    let sortedNumbers = profileManager.availableNumbers(excluding: profile).sorted { num1, num2 in
                        if numberOrder == "rightHanded" {
                            // Right handed: 0, 9, 8, ..., 1
                            let order1 = num1 == 0 ? 0 : (11 - num1)
                            let order2 = num2 == 0 ? 0 : (11 - num2)
                            return order1 < order2
                        } else {
                            // Left handed: 1, 2, ..., 9, 0
                            if num1 == 0 { return false }
                            if num2 == 0 { return true }
                            return num1 < num2
                        }
                    }
                    
                    ForEach(sortedNumbers, id: \.self) { number in
                        Text("\(number)").tag(number as Int?)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: profile.profileNumber) { _, _ in
                    profileManager.setProfileNumber(profile, number: profile.profileNumber)
                }
            } footer: {
                if let number = profile.profileNumber {
                    Text("\(modifierManager.profileModifierSymbols)\(number)")
                        .foregroundStyle(.tertiary)
                } else {
                    Text("No shortcut assigned")
                        .foregroundStyle(.tertiary)
                }
            }
            
            Section("Application Bindings") {
                ForEach(numbersInOrder, id: \.self) { number in
                    HStack {
                        Text("\(number):")
                            .frame(width: 30, alignment: .leading)
                        
                        if let app = profile[number],
                           let bundleUrl = app.bundleUrl {
                            Text(bundleUrl.deletingPathExtension().lastPathComponent)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Button("Remove") {
                                profile.unbind(app)
                                try? profileManager.modelContext.save()
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
            if let app = Application(url: url) {
                profile.bind(app, number)
                try? profileManager.modelContext.save()
            }
        }
    }
}
