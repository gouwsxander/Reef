//
//  PreferencesProfilesView.swift
//  Reef
//
//  Created by Xander Gouws on 28-01-2026.
//

import SwiftUI
import UniformTypeIdentifiers

struct PreferencesProfilesView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @AppStorage("defaultNumberOrder") private var defaultNumberOrder = "rightHanded"
    @StateObject private var modifierManager: ModifierManager = {
        if let manager = AppDelegate.modifierManager {
            return manager
        }
        return ModifierManager()
    }()
    private var profiles: [Profile] { profileManager.profiles }
    
    private var sortedProfiles: [Profile] {
        let numberedProfiles = profiles.filter { $0.profileNumber != nil }
        let unnumberedProfiles = profiles.filter { $0.profileNumber == nil }
        
        let sortedNumbered = numberedProfiles.sorted { profile1, profile2 in
            guard let num1 = profile1.profileNumber, let num2 = profile2.profileNumber else {
                return false
            }
            
            if defaultNumberOrder == "rightHanded" {
                let order1 = num1 == 0 ? 0 : (11 - num1)
                let order2 = num2 == 0 ? 0 : (11 - num2)
                return order1 < order2
            } else {
                if num1 == 0 { return false }
                if num2 == 0 { return true }
                return num1 < num2
            }
        }
        
        return sortedNumbered + unnumberedProfiles.sorted { $0.createdAt < $1.createdAt }
    }
    
    @State private var selectedProfileID: UUID?
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                List(sortedProfiles, id: \.id, selection: $selectedProfileID) { profile in
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
                    .tag(profile.id)
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
                    .disabled(sortedProfiles.count <= 1 || selectedProfileID == nil)
                    
                    Spacer()
                }
                .padding(8)
            }
            .frame(width: 200)
            
            Divider()
            
            if let selectedProfileID = selectedProfileID,
               let selectedIndex = profiles.firstIndex(where: { $0.id == selectedProfileID }) {
                ProfileDetailView(
                    profile: $profileManager.profiles[selectedIndex],
                    profileManager: profileManager,
                    modifierManager: modifierManager
                )
            } else {
                Text("Select a profile")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(height: 635)
        .onAppear {
            if selectedProfileID == nil {
                selectedProfileID = profileManager.currentProfileID
            }
        }
    }
    
    private func addProfile() {
        let newProfile = profileManager.createProfile(name: "New Profile")
        selectedProfileID = newProfile.id
    }
    
    private func removeProfile() {
        guard sortedProfiles.count > 1,
              let selectedID = selectedProfileID,
              let selectedIndex = sortedProfiles.firstIndex(where: { $0.id == selectedID }) else {
            return
        }
        
        let selectedProfile = sortedProfiles[selectedIndex]
        
        // Pick the next profile below, or fall back to the one above
        let nextIndex = selectedIndex + 1 < sortedProfiles.count ? selectedIndex + 1 : selectedIndex - 1
        let nextProfile = sortedProfiles[nextIndex]
        
        if selectedProfile.id == profileManager.currentProfileID {
            profileManager.switchProfile(nextProfile)
        }
        
        profileManager.deleteProfile(selectedProfile)
        selectedProfileID = nextProfile.id
    }
}

struct ProfileDetailView: View {
    @Binding var profile: Profile
    @ObservedObject var profileManager: ProfileManager
    @ObservedObject var modifierManager: ModifierManager
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
                .onChange(of: profile.profileNumber) { oldValue, newValue in
                    if !profileManager.setProfileNumber(profile, number: newValue) {
                        profile.profileNumber = oldValue
                    }
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
            
            Section {
                ForEach(numbersInOrder, id: \.self) { number in
                    BindingRow(
                        number: number,
                        bundleIdentifier: profileManager.bundleIdentifier(for: number, in: profile),
                        onRemove: { profileManager.unbind(slot: number, in: profile) },
                        onChoose: { chooseApplication(for: number) },
                        onDrop: { providers in handleDrop(providers, onto: number) }
                    )
                }
            } header: {
                Text("Application Bindings")
            } footer: {
                Text("Drag a bound application onto another number to reassign it, or drop an app from Finder onto a number.")
                    .foregroundStyle(.tertiary)
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
            bindApplication(at: url, to: number)
        }
    }
    
    // Accepts either a binding dragged from another slot or an application dropped from Finder.
    private func handleDrop(_ providers: [NSItemProvider], onto slot: Int) -> Bool {
        let target = profile
        let slotType = UTType.reefBindingSlot.identifier
        
        if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(slotType) }) {
            provider.loadDataRepresentation(forTypeIdentifier: slotType) { data, _ in
                guard let data, let source = Int(String(decoding: data, as: UTF8.self)) else { return }
                Task { @MainActor in
                    profileManager.moveBinding(from: source, to: slot, in: target)
                }
            }
            return true
        }
        
        guard let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) }) else {
            return false
        }
        
        _ = provider.loadObject(ofClass: URL.self) { url, _ in
            guard let url else { return }
            Task { @MainActor in
                bindApplication(at: url, to: slot, in: target)
            }
        }
        return true
    }
    
    private func bindApplication(at url: URL, to slot: Int, in target: Profile? = nil) {
        guard let contentType = try? url.resourceValues(forKeys: [.contentTypeKey]).contentType,
              contentType.conforms(to: .application),
              let app = Application(url: url),
              let bundleIdentifier = app.bundleIdentifier else {
            NSSound.beep()
            return
        }
        
        profileManager.bind(bundleIdentifier: bundleIdentifier, to: slot, in: target ?? profile)
    }
}

private struct BindingRow: View {
    let number: Int
    let bundleIdentifier: String?
    let onRemove: () -> Void
    let onChoose: () -> Void
    let onDrop: ([NSItemProvider]) -> Bool
    
    @State private var isTargeted = false
    
    var body: some View {
        let application = bundleIdentifier.flatMap { Application(bundleIdentifier: $0) }
        
        HStack {
            if let bundleIdentifier {
                // The handle, number and name form one grab area, so the row can be
                // picked up from the handle on the left or from the application itself.
                HStack {
                    dragHandle
                    slotNumber
                    label(for: application, fallback: bundleIdentifier)
                }
                .contentShape(Rectangle())
                .onDrag(makeItemProvider) {
                    label(for: application, fallback: bundleIdentifier)
                }
                .help("Drag onto another number to reassign this application")
                
                Spacer()
                
                Button("Remove", action: onRemove)
                    .buttonStyle(.borderless)
            } else {
                HStack {
                    dragHandle
                        .hidden()
                    slotNumber
                    
                    Text("Not set")
                        .foregroundStyle(.tertiary)
                }
                
                Spacer()
            }
            
            Button("Choose application...", action: onChoose)
                .buttonStyle(.borderless)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(Color.accentColor, lineWidth: 2)
                .padding(-4)
                .opacity(isTargeted ? 1 : 0)
        }
        .animation(.easeOut(duration: 0.1), value: isTargeted)
        .contentShape(Rectangle())
        .onDrop(of: [.reefBindingSlot, .fileURL], isTargeted: $isTargeted) { providers, _ in
            onDrop(providers)
        }
    }
    
    private var dragHandle: some View {
        Image(systemName: "line.3.horizontal")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .frame(width: 12)
            .accessibilityHidden(true)
    }
    
    private var slotNumber: some View {
        Text("\(number):")
            .frame(width: 30, alignment: .leading)
    }
    
    private func label(for application: Application?, fallback: String) -> some View {
        Text(application?.title ?? fallback)
            .foregroundStyle(.secondary)
    }
    
    private func makeItemProvider() -> NSItemProvider {
        let provider = NSItemProvider()
        provider.registerDataRepresentation(
            forTypeIdentifier: UTType.reefBindingSlot.identifier,
            visibility: .ownProcess
        ) { completion in
            completion(Data(String(number).utf8), nil)
            return nil
        }
        return provider
    }
}
