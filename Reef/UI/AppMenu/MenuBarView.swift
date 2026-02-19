//
//  MenuBarView.swift
//  Reef
//
//  Created by Xander Gouws on 28-01-2026.
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var sparkleConnector: SparkleConnector
    private var profiles: [Profile] { profileManager.profiles }
    
    @Environment(\.openSettings) private var openSettings
    @AppStorage("defaultNumberOrder") private var defaultNumberOrder = "rightHanded"
    
    @StateObject private var modifierManager: ModifierManager = {
        if let manager = AppDelegate.modifierManager {
            return manager
        }
        return ModifierManager()
    }()
    
    private let settingsWindowIdentifier = NSUserInterfaceItemIdentifier("Reef.SettingsWindow")
    
    // Helper function to get number based on order preference
    private func getNumber(for index: Int, order: String) -> Int {
        if order == "rightHanded" {
            return (10 - index) % 10
        } else {
            return (index + 1) % 10
        }
    }
    
    // Helper to get sorted profiles based on default number order
    private var sortedProfiles: [Profile] {
        // Separate profiles with and without numbers
        let numberedProfiles = profiles.filter { $0.profileNumber != nil }
        let unnumberedProfiles = profiles.filter { $0.profileNumber == nil }
        
        // Sort numbered profiles based on defaultNumberOrder
        let sortedNumbered: [Profile]
        if defaultNumberOrder == "rightHanded" {
            // Right handed: 0, 9, 8, ..., 1
            sortedNumbered = numberedProfiles.sorted { profile1, profile2 in
                guard let num1 = profile1.profileNumber, let num2 = profile2.profileNumber else {
                    return false
                }
                // Convert to right-handed order for comparison
                let order1 = num1 == 0 ? 0 : (11 - num1)
                let order2 = num2 == 0 ? 0 : (11 - num2)
                return order1 < order2
            }
        } else {
            // Left handed: 1, 2, ..., 9, 0
            sortedNumbered = numberedProfiles.sorted { profile1, profile2 in
                guard let num1 = profile1.profileNumber, let num2 = profile2.profileNumber else {
                    return false
                }
                // 0 goes last in left-handed
                if num1 == 0 { return false }
                if num2 == 0 { return true }
                return num1 < num2
            }
        }
        
        // Append unnumbered profiles sorted by creation date
        return sortedNumbered + unnumberedProfiles.sorted { $0.createdAt < $1.createdAt }
    }
    
    private func isLikelySettingsWindow(_ window: NSWindow) -> Bool {
        if window.identifier == settingsWindowIdentifier {
            return true
        }
        
        let windowClass = String(describing: type(of: window))
        return windowClass.contains("AppKitWindow")
    }
    
    private func bringSettingsWindowToFrontIfPresent() -> Bool {
        guard let settingsWindow = NSApp.windows.first(where: { isLikelySettingsWindow($0) }) else {
            return false
        }
        
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow.orderFrontRegardless()
        settingsWindow.makeKeyAndOrderFront(nil)
        return true
    }
    
    private func openPreferencesWindow() {
        NSApp.activate(ignoringOtherApps: true)
        openSettings()
        
        Task { @MainActor in
            for _ in 0..<6 {
                if bringSettingsWindowToFrontIfPresent() {
                    return
                }
                
                try? await Task.sleep(nanoseconds: 50_000_000)
            }
        }
    }
    
    var body: some View {
        Text("Applications")
        
        // Bindings - use current profile's numberOrder or fall back to default
        let currentProfile = profileManager.currentProfile
        let numberOrder = currentProfile?.numberOrder ?? defaultNumberOrder
        ForEach(Array(stride(from: 0, through: 9, by: 1)), id: \.self) { i in
            let number = getNumber(for: i, order: numberOrder)
            if let binding = profileManager.application(for: number, in: currentProfile) {
                if modifierManager.activateEnabled {
                    Button("\(binding.title)") {
                        binding.focus()
                    }
                    .keyboardShortcut(KeyEquivalent(Character("\(number)")), modifiers: modifierManager.activateEventModifiers)
                } else {
                    Button("\(binding.title)") {
                        binding.focus()
                    }
                }
            }
        }
        
        Divider()
        
        Text("Profiles")
        
        ForEach(sortedProfiles) { profile in
            if modifierManager.profileEnabled, let profileNumber = profile.profileNumber {
                Button(profile.name) {
                    profileManager.switchProfile(profile)
                }
                .keyboardShortcut(KeyEquivalent(Character("\(profileNumber)")), modifiers: modifierManager.profileEventModifiers)
            } else {
                Button(profile.name) {
                    profileManager.switchProfile(profile)
                }
            }
        }
        
        Divider()

        Button("Check for Updates") {
            sparkleConnector.checkForUpdates()
        }
        .disabled(!sparkleConnector.canCheckForUpdates)

        Button("Preferences...") {
            openPreferencesWindow()
        }
        
        Button("About Reef") {
            NSApp.orderFrontStandardAboutPanel()
        }
        
        Button("Quit") {
            NSApp.terminate(nil)
        }
    }
}
