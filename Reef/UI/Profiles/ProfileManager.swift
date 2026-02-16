//
//  ProfileManager.swift
//  Reef
//
//  Created by Xander Gouws on 31-01-2026.
//

import SwiftUI
import Foundation

@MainActor
final class ProfileManager: ObservableObject {
    @Published var profiles: [Profile] = [] {
        didSet { scheduleSave() }
    }
    @Published var currentProfileID: UUID? {
        didSet { scheduleSave() }
    }

    private let storeURL: URL
    private var isLoading = false
    private var saveTask: Task<Void, Never>?

    init(storeURL: URL? = nil) {
        self.storeURL = storeURL ?? Self.defaultStoreURL()
        load()
    }

    var currentProfile: Profile? {
        guard let currentProfileID else { return nil }
        return profiles.first(where: { $0.id == currentProfileID })
    }

    func switchProfile(_ profile: Profile) {
        switchProfile(id: profile.id)
    }

    func switchProfile(id: UUID) {
        currentProfileID = id
        touchLastUsed(id: id)
    }

    func createProfile(name: String, numberOrder: String? = nil) -> Profile {
        var profile = Profile(name: name, numberOrder: numberOrder)
        profile.bindings = Profile.normalizedBindings(profile.bindings)
        profiles.append(profile)

        if currentProfileID == nil {
            currentProfileID = profile.id
        }

        return profile
    }

    func deleteProfile(_ profile: Profile) {
        profiles.removeAll { $0.id == profile.id }

        if currentProfileID == profile.id {
            currentProfileID = profiles.first?.id
        }
    }

    // Assigns or removes a profile number. Enforces uniqueness — returns false
    // if the requested number is already taken by another profile.
    @discardableResult
    func setProfileNumber(_ profile: Profile, number: Int?) -> Bool {
        if let number = number {
            if let existing = profileID(forNumber: number), existing != profile.id {
                return false
            }
        }

        updateProfile(id: profile.id) { updated in
            updated.profileNumber = number
        }
        return true
    }

    // Returns which of 0–9 are available for the given profile.
    // Includes numbers not taken by anyone, plus the profile's own current number.
    func availableNumbers(excluding profile: Profile) -> [Int] {
        (0...9).filter { number in
            let existing = profileID(forNumber: number)
            return existing == nil || existing == profile.id
        }
    }

    func bind(bundleIdentifier: String, to slot: Int, in profile: Profile? = nil) {
        guard let targetID = (profile ?? currentProfile)?.id else { return }
        updateProfile(id: targetID) { updated in
            updated.bind(bundleIdentifier: bundleIdentifier, slot: slot)
        }
    }

    func unbind(slot: Int, in profile: Profile? = nil) {
        guard let targetID = (profile ?? currentProfile)?.id else { return }
        updateProfile(id: targetID) { updated in
            updated.unbind(slot: slot)
        }
    }

    func unbind(bundleIdentifier: String, in profile: Profile? = nil) {
        guard let targetID = (profile ?? currentProfile)?.id else { return }
        updateProfile(id: targetID) { updated in
            updated.unbind(bundleIdentifier: bundleIdentifier)
        }
    }

    func bundleIdentifier(for slot: Int, in profile: Profile? = nil) -> String? {
        guard let target = profile ?? currentProfile else { return nil }
        return target.bundleIdentifier(for: slot)
    }

    func application(for slot: Int, in profile: Profile? = nil) -> Application? {
        guard let bundleIdentifier = bundleIdentifier(for: slot, in: profile) else {
            return nil
        }
        return Application(bundleIdentifier: bundleIdentifier)
    }

    func saveNow() {
        let state = ProfileStoreState(
            schemaVersion: 1,
            currentProfileID: currentProfileID,
            profiles: profiles.map { profile in
                var normalized = profile
                normalized.bindings = Profile.normalizedBindings(profile.bindings)
                return normalized
            }
        )

        do {
            let data = try ProfileStoreState.encoder.encode(state)
            try writeAtomically(data: data, to: storeURL)
        } catch {
            print("Failed to save profiles: \(error)")
        }
    }

    private func scheduleSave() {
        guard !isLoading else { return }
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            self?.saveNow()
        }
    }

    private func load() {
        isLoading = true
        defer { isLoading = false }

        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            let defaultProfile = Profile(name: "Default")
            profiles = [defaultProfile]
            currentProfileID = defaultProfile.id
            return
        }

        do {
            let data = try Data(contentsOf: storeURL)
            let state = try ProfileStoreState.decoder.decode(ProfileStoreState.self, from: data)
            profiles = state.profiles.map { profile in
                var normalized = profile
                normalized.bindings = Profile.normalizedBindings(profile.bindings)
                return normalized
            }

            if profiles.isEmpty {
                let defaultProfile = Profile(name: "Default")
                profiles = [defaultProfile]
                currentProfileID = defaultProfile.id
                return
            }

            if let current = state.currentProfileID,
               profiles.contains(where: { $0.id == current }) {
                currentProfileID = current
            } else {
                currentProfileID = profiles.first?.id
            }
        } catch {
            print("Failed to load profiles: \(error)")
            let defaultProfile = Profile(name: "Default")
            profiles = [defaultProfile]
            currentProfileID = defaultProfile.id
        }
    }

    private func updateProfile(id: UUID, mutate: (inout Profile) -> Void) {
        guard let index = profiles.firstIndex(where: { $0.id == id }) else { return }
        var updated = profiles[index]
        mutate(&updated)
        profiles[index] = updated
    }

    private func touchLastUsed(id: UUID) {
        updateProfile(id: id) { updated in
            updated.lastUsedAt = .now
        }
    }

    func profileID(forNumber number: Int) -> UUID? {
        profiles.first(where: { $0.profileNumber == number })?.id
    }

    private func writeAtomically(data: Data, to url: URL) throws {
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try data.write(to: url, options: .atomic)
            return
        }

        let tmpURL = directory.appendingPathComponent(".profiles.json.tmp")
        try data.write(to: tmpURL, options: .atomic)
        defer { try? FileManager.default.removeItem(at: tmpURL) }
        _ = try FileManager.default.replaceItemAt(url, withItemAt: tmpURL)
    }

    nonisolated private static func defaultStoreURL() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let bundleID = Bundle.main.bundleIdentifier ?? "Reef"
        return base.appendingPathComponent(bundleID, isDirectory: true)
            .appendingPathComponent("profiles.json")
    }
}

private struct ProfileStoreState: Codable {
    let schemaVersion: Int
    let currentProfileID: UUID?
    let profiles: [Profile]

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
