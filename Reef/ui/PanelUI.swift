//
//  PanelUI.swift
//  Reef
//
//  Created by Xander Gouws on 19-01-2026.
//

import SwiftUI

struct PanelUI: View {
    @ObservedObject var model: SwitcherViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Text(model.title)
                .font(.headline)
                .padding(.top, 8)
                .padding(.bottom, 10)
                .padding(.horizontal, 16)
            
            Divider()
            
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(model.items.enumerated()), id: \.element.id) { index, element in
                        HStack {
                            Text(element.title)
                                .foregroundColor(index == model.selectedIndex ? .white : .primary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(index == model.selectedIndex ? Color.accentColor : Color.clear)
                        .cornerRadius(6)
                        .onTapGesture {
                            model.selectedIndex = index
                        }
                    }
                }
                .padding(8)
            }
        }
        .frame(width: 400, height: 300)
        .ignoresSafeArea(.container, edges: .top)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.01))
    }
}
