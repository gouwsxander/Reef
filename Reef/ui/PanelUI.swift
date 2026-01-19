//
//  PanelUI.swift
//  Reef
//
//  Created by Xander Gouws on 19-01-2026.
//

import SwiftUI

struct PanelUI: View {
    @State private var elements = ["Element A", "Element B", "Element C", "Element D"]
    @State private var selectedIndex = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Select Window")
                .font(.headline)
                .padding()
            
            Divider()
            
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(elements.enumerated()), id: \.offset) { index, element in
                        HStack {
                            Text(element)
                                .foregroundColor(index == selectedIndex ? .white : .primary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(index == selectedIndex ? Color.accentColor : Color.clear)
                        .cornerRadius(6)
                        .onTapGesture {
                            selectedIndex = index
                        }
                    }
                }
                .padding(8)
            }
        }
        .frame(width: 400, height: 300)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.01))
    }
}
