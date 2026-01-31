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
        return profile
    }
    
    func deleteProfile(_ profile: Bindings) {
        modelContext.delete(profile)
        try? modelContext.save()
    }
}
