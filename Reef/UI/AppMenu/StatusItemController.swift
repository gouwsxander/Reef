//
//  StatusItemController.swift
//  Reef
//

import AppKit

@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private let profileManager: ProfileManager
    private let sparkleConnector: SparkleConnector
    private let modifierManager: ModifierManager
    private let menu = NSMenu()
    private var statusItem: NSStatusItem?

    init(
        profileManager: ProfileManager,
        sparkleConnector: SparkleConnector,
        modifierManager: ModifierManager
    ) {
        self.profileManager = profileManager
        self.sparkleConnector = sparkleConnector
        self.modifierManager = modifierManager
        super.init()

        menu.delegate = self
        setHidden(UserDefaults.standard.bool(forKey: "hideMenubarIcon"))
    }

    func setHidden(_ hidden: Bool) {
        if hidden {
            removeStatusItem()
        } else {
            createStatusItemIfNeeded()
        }
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        rebuildMenu()
    }

    private func createStatusItemIfNeeded() {
        guard statusItem == nil else { return }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = item.button {
            button.image = NSImage(named: "menu_placeholder")
            button.image?.isTemplate = true
            button.toolTip = "Reef"
        }
        item.menu = menu
        statusItem = item
    }

    private func removeStatusItem() {
        guard let statusItem else { return }
        NSStatusBar.system.removeStatusItem(statusItem)
        self.statusItem = nil
    }

    private func rebuildMenu() {
        menu.removeAllItems()
        addHeader("Applications")
        addApplicationItems()
        menu.addItem(.separator())
        addHeader("Profiles")
        addProfileItems()
        menu.addItem(.separator())
        addUtilityItems()
    }

    private func addHeader(_ title: String) {
        let item = NSMenuItem(title: title, action: nil, keyEquivalent: "")
        item.isEnabled = false
        menu.addItem(item)
    }

    private func addApplicationItems() {
        let currentProfile = profileManager.currentProfile
        let numberOrder = currentProfile?.numberOrder
            ?? UserDefaults.standard.string(forKey: "defaultNumberOrder")
            ?? "rightHanded"

        for index in 0...9 {
            let number = menuNumber(for: index, order: numberOrder)
            guard let application = profileManager.application(for: number, in: currentProfile) else { continue }

            let item = NSMenuItem(
                title: application.title,
                action: #selector(activateApplication(_:)),
                keyEquivalent: modifierManager.activateEnabled ? String(number) : ""
            )
            item.target = self
            item.representedObject = application
            item.keyEquivalentModifierMask = modifierManager.activateModifiers
            menu.addItem(item)
        }
    }

    private func addProfileItems() {
        for profile in sortedProfiles {
            let item = NSMenuItem(
                title: profile.name,
                action: #selector(switchProfile(_:)),
                keyEquivalent: profileKeyEquivalent(for: profile)
            )
            item.target = self
            item.representedObject = profile.id
            item.keyEquivalentModifierMask = modifierManager.profileModifiers
            menu.addItem(item)
        }
    }

    private func addUtilityItems() {
        let updateItem = NSMenuItem(
            title: "Check for updates...",
            action: #selector(checkForUpdates),
            keyEquivalent: ""
        )
        updateItem.target = self
        updateItem.isEnabled = sparkleConnector.canCheckForUpdates
        menu.addItem(updateItem)

        menu.addItem(actionItem(title: "Preferences...", action: #selector(openPreferences)))
        menu.addItem(actionItem(title: "About Reef", action: #selector(showAbout)))
        menu.addItem(actionItem(title: "Quit", action: #selector(quit)))
    }

    private func actionItem(title: String, action: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: "")
        item.target = self
        return item
    }

    private func menuNumber(for index: Int, order: String) -> Int {
        if order == "rightHanded" {
            return (10 - index) % 10
        }
        return (index + 1) % 10
    }

    private var sortedProfiles: [Profile] {
        let numberedProfiles = profileManager.profiles.filter { $0.profileNumber != nil }
        let unnumberedProfiles = profileManager.profiles.filter { $0.profileNumber == nil }

        let sortedNumbered: [Profile]
        if UserDefaults.standard.string(forKey: "defaultNumberOrder") == "leftHanded" {
            sortedNumbered = numberedProfiles.sorted { first, second in
                guard let firstNumber = first.profileNumber, let secondNumber = second.profileNumber else {
                    return false
                }
                if firstNumber == 0 { return false }
                if secondNumber == 0 { return true }
                return firstNumber < secondNumber
            }
        } else {
            sortedNumbered = numberedProfiles.sorted { first, second in
                guard let firstNumber = first.profileNumber, let secondNumber = second.profileNumber else {
                    return false
                }
                let firstOrder = firstNumber == 0 ? 0 : (11 - firstNumber)
                let secondOrder = secondNumber == 0 ? 0 : (11 - secondNumber)
                return firstOrder < secondOrder
            }
        }

        return sortedNumbered + unnumberedProfiles.sorted { $0.createdAt < $1.createdAt }
    }

    private func profileKeyEquivalent(for profile: Profile) -> String {
        guard modifierManager.profileEnabled, let profileNumber = profile.profileNumber else { return "" }
        return String(profileNumber)
    }

    @objc private func activateApplication(_ sender: NSMenuItem) {
        guard let application = sender.representedObject as? Application else { return }
        application.focus()
    }

    @objc private func switchProfile(_ sender: NSMenuItem) {
        guard let profileID = sender.representedObject as? UUID else { return }
        profileManager.switchProfile(id: profileID)
    }

    @objc private func checkForUpdates() {
        sparkleConnector.checkForUpdates()
    }

    @objc private func openPreferences() {
        AppDelegate.instance.openPreferencesWindow()
    }

    @objc private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel()
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
