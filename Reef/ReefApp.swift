//
//  ReefApp.swift
//  Reef
//
//  Created by Xander Gouws on 12-09-2025.
//

import SwiftUI
import KeyboardShortcuts

@main
struct ReefApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var bindings = Bindings("Default")

    var body: some Scene {
        Settings {
            PreferencesView()
                .frame(minWidth: 500, minHeight: 200)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .defaultSize(width: 500, height: 200)
        
        MenuBarExtra {
            MenuBarContent(bindings: bindings)
        } label: {
            Image(systemName: "fish.fill")
        }
    }
}

struct MenuBarContent: View {
    @ObservedObject var bindings: Bindings
    
    var body: some View {
        ForEach(Array(stride(from: 9, through: 0, by: -1)), id: \.self) { i in
            let number = i
            if let binding = bindings[number] {
                Button("\(number) | \(binding.title)") {
                    binding.focus()
                }
            }
        }
        
        Divider()
        
        SettingsLink {
            Text("Preferences...")
        }
        
        Divider()
        
        Button("About Reef") {
            NSApp.orderFrontStandardAboutPanel()
        }
        
        Button("Quit") {
            NSApp.terminate(nil)
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    
    private var cycleController: CyclePanelController!
    private var shortcutManager: ShortcutController!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        
        let bindings = Bindings("Default")
        cycleController = CyclePanelController()
        shortcutManager = ShortcutController(cycleController, bindings)
        
        // Make settings visible anywhere?
        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeKeyNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let window = notification.object as? NSWindow,
               String(describing: type(of: window)).contains("Settings") {
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            }
        }
    }
}
