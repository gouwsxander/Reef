//
//  ProfileManager.swift
//  Reef
//
//  Created by Xander Gouws on 31-01-2026.
//

import SwiftUI
import SwiftData

@MainActor
class ProfileManager: ObservableObject {
    @Published var currentProfile: Profile
    
    let modelContext: ModelContext
    
    private(set) var profilesByNumber: [Int: Profile] = [:]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        let descriptor = FetchDescriptor<Profile>(
            sortBy: [SortDescriptor(\.lastUsedDate, order: .reverse)]
        )
        
        do {
            let fetchedProfiles = try modelContext.fetch(descriptor)
            
            if fetchedProfiles.isEmpty {
                let defaultProfile = Profile(name: "Default")
                modelContext.insert(defaultProfile)
                try modelContext.save()
                self.currentProfile = defaultProfile
            } else {
                self.currentProfile = fetchedProfiles.first!
            }
        } catch {
            let defaultProfile = Profile(name: "Default")
            self.currentProfile = defaultProfile
            modelContext.insert(defaultProfile)
            try? modelContext.save()
        }
        
        rebuildNumberCache()
    }
    
    func switchProfile(_ profile: Profile) {
        currentProfile = profile
        currentProfile.lastUsedDate = Date.now
        save()
        objectWillChange.send()
    }
    
    func createProfile(name: String, numberOrder: String? = nil) -> Profile {
        let profile = Profile(name: name, numberOrder: numberOrder)
        modelContext.insert(profile)
        save()
        rebuildNumberCache()
        return profile
    }
    
    func deleteProfile(_ profile: Profile) {
        modelContext.delete(profile)
        save()
        rebuildNumberCache()
    }
    
    // Assigns or removes a profile number. Enforces uniqueness — returns false
    // if the requested number is already taken by another profile.
    @discardableResult
    func setProfileNumber(_ profile: Profile, number: Int?) -> Bool {
        if let number = number {
            // Check uniqueness: the number must not be owned by a *different* profile
            if let existing = profilesByNumber[number], existing.persistentModelID != profile.persistentModelID {
                return false
            }
        }
        
        profile.profileNumber = number
        save()
        rebuildNumberCache()
        return true
    }
    
    // Returns which of 0–9 are available for the given profile.
    // Includes numbers not taken by anyone, plus the profile's own current number.
    func availableNumbers(excluding profile: Profile) -> [Int] {
        (0...9).filter { number in
            profilesByNumber[number] == nil ||
            profilesByNumber[number]?.persistentModelID == profile.persistentModelID
        }
    }

    func bind(bundleIdentifier: String, to slot: Int, in profile: Profile? = nil) {
        let targetProfile = profile ?? currentProfile
        targetProfile.bindings.bind(bundleIdentifier: bundleIdentifier, slot: slot)
        save()
        objectWillChange.send()
    }

    func unbind(slot: Int, in profile: Profile? = nil) {
        let targetProfile = profile ?? currentProfile
        targetProfile.bindings.unbind(slot: slot)
        save()
        objectWillChange.send()
    }

    func unbind(bundleIdentifier: String, in profile: Profile? = nil) {
        let targetProfile = profile ?? currentProfile
        targetProfile.bindings.unbind(bundleIdentifier: bundleIdentifier)
        save()
        objectWillChange.send()
    }

    func bundleIdentifier(for slot: Int, in profile: Profile? = nil) -> String? {
        let targetProfile = profile ?? currentProfile
        return targetProfile.bindings.bundleIdentifier(for: slot)
    }

    func application(for slot: Int, in profile: Profile? = nil) -> Application? {
        guard let bundleIdentifier = bundleIdentifier(for: slot, in: profile) else {
            return nil
        }
        return Application(bundleIdentifier: bundleIdentifier)
    }

    func save() {
        try? modelContext.save()
    }

    private func rebuildNumberCache() {
        profilesByNumber = [:]
        
        let descriptor = FetchDescriptor<Profile>()
        guard let profiles = try? modelContext.fetch(descriptor) else { return }
        
        for profile in profiles {
            if let number = profile.profileNumber {
                profilesByNumber[number] = profile
            }
        }
    }
}
