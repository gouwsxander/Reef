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
    @Published var currentProfile: Bindings
    
    let modelContext: ModelContext
    
    private(set) var profilesByNumber: [Int: Bindings] = [:]
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        let descriptor = FetchDescriptor<Bindings>(
            sortBy: [SortDescriptor(\.lastUsedDate, order: .reverse)]
        )
        
        do {
            let fetchedProfiles = try modelContext.fetch(descriptor)
            
            if fetchedProfiles.isEmpty {
                let defaultProfile = Bindings("Default")
                modelContext.insert(defaultProfile)
                try modelContext.save()
                self.currentProfile = defaultProfile
            } else {
                self.currentProfile = fetchedProfiles.first!
            }
            
            currentProfile.loadApplications()
        } catch {
            let defaultProfile = Bindings("Default")
            self.currentProfile = defaultProfile
            modelContext.insert(defaultProfile)
            try? modelContext.save()
        }
        
        rebuildNumberCache()
    }
    
    func switchProfile(_ profile: Bindings) {
        currentProfile = profile
        currentProfile.lastUsedDate = Date.now
        currentProfile.loadApplications()
        try? modelContext.save()
        objectWillChange.send()
    }
    
    func createProfile(name: String, numberOrder: String? = nil) -> Bindings {
        let profile = Bindings(name, numberOrder: numberOrder)
        modelContext.insert(profile)
        try? modelContext.save()
        rebuildNumberCache()
        return profile
    }
    
    func deleteProfile(_ profile: Bindings) {
        modelContext.delete(profile)
        try? modelContext.save()
        rebuildNumberCache()
    }
    
    // Assigns or removes a profile number. Enforces uniqueness — returns false
    // if the requested number is already taken by another profile.
    @discardableResult
    func setProfileNumber(_ profile: Bindings, number: Int?) -> Bool {
        if let number = number {
            // Check uniqueness: the number must not be owned by a *different* profile
            if let existing = profilesByNumber[number], existing.persistentModelID != profile.persistentModelID {
                return false
            }
        }
        
        profile.profileNumber = number
        try? modelContext.save()
        rebuildNumberCache()
        return true
    }
    
    // Returns which of 0–9 are available for the given profile.
    // Includes numbers not taken by anyone, plus the profile's own current number.
    func availableNumbers(excluding profile: Bindings) -> [Int] {
        (0...9).filter { number in
            profilesByNumber[number] == nil ||
            profilesByNumber[number]?.persistentModelID == profile.persistentModelID
        }
    }
    
    
    
    private func rebuildNumberCache() {
        profilesByNumber = [:]
        
        let descriptor = FetchDescriptor<Bindings>()
        guard let profiles = try? modelContext.fetch(descriptor) else { return }
        
        for profile in profiles {
            if let number = profile.profileNumber {
                profilesByNumber[number] = profile
            }
        }
    }
}
