//
//  MenuBarView.swift
//  Reef
//
//  Created by Xander Gouws on 28-01-2026.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var bindings: Bindings
    @Environment(\.openSettings) private var openSettings
    
    var body: some View {
        ForEach(Array(stride(from: 0, through: 9, by: 1)), id: \.self) { i in
            let number = (10 - i) % 10
            if let binding = bindings[number] {
                Button("\(number) | \(binding.title)") {
                    binding.focus()
                }
            }
        }
        
        Divider()
        
        Button("Preferences...") {
            openSettings()
        }
        
        Button("About Reef") {
            NSApp.orderFrontStandardAboutPanel()
        }
        
        Button("Quit") {
            NSApp.terminate(nil)
        }
    }
}
