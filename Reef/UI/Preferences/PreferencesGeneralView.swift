//
//  PreferencesGeneralView.swift
//  Reef
//
//  Created by Xander Gouws on 26-01-2026.
//

import SwiftUI
import ServiceManagement
import ApplicationServices

struct PreferencesGeneralView: View {
    @AppStorage("launchOnLogin") private var launchOnLogin = true
//    @AppStorage("hideMenubarIcon") private var hideMenubarIcon = false
    @AppStorage("appearance") private var appearance = "system"
    @AppStorage("defaultNumberOrder") private var defaultNumberOrder = "rightHanded"
    @AppStorage(InstantSwitchMode.defaultsKey) private var instantSwitchMode = InstantSwitchMode.never.rawValue
    
    @State private var hasAccessibilityPermission = AXIsProcessTrusted()
    
    // Timer to poll for accessibility permission changes
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Form {
            // Accessibility Permission Warning
            if !hasAccessibilityPermission {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .imageScale(.large)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Accessibility Permission Required")
                            .fontWeight(.medium)
                        Text("System Settings → Privacy & Security → Accessibility")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button("Open Settings") {
                        openAccessibilitySettings()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            Section {
                Toggle("Launch Reef at login", isOn: $launchOnLogin)
                    .onChange(of: launchOnLogin) { _, newValue in
                        setLaunchAtLogin(enabled: newValue)
                    }
                
//                Toggle("Hide menubar icon", isOn: $hideMenubarIcon)
                
                
                Picker("Default number order:", selection: $defaultNumberOrder) {
                    Text("Right handed (0, 9, ..., 1)").tag("rightHanded")
                    Text("Left handed (1, ..., 9, 0)").tag("leftHanded")
                }
                .pickerStyle(.menu)

                Picker("Instant switching:", selection: $instantSwitchMode) {
                    Text("Never").tag(InstantSwitchMode.never.rawValue)
                    Text("Single-window apps").tag(InstantSwitchMode.singleWindow.rawValue)
                    Text("Always").tag(InstantSwitchMode.always.rawValue)
                }
                .pickerStyle(.menu)
            } footer: {
                Text("Number order controls the menubar display. Instant switching focuses windows on key down; single-window mode keeps the switcher for apps with no windows.")
            }
        }
        .formStyle(.grouped)
        .frame(height: hasAccessibilityPermission ? 175 : 240)
        .onReceive(timer) { _ in
            // Poll for permission changes
            hasAccessibilityPermission = AXIsProcessTrusted()
        }
    }
    
    private func openAccessibilitySettings() {
        // Open System Settings to the Privacy & Security > Accessibility pane
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    private func setLaunchAtLogin(enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
                // Revert the toggle if it failed
                DispatchQueue.main.async {
                    launchOnLogin = !enabled
                }
            }
        } else {
            // Legacy API for macOS 12 and earlier
            SMLoginItemSetEnabled(Bundle.main.bundleIdentifier! as CFString, enabled)
        }
    }
}

#Preview {
    PreferencesGeneralView()
}
