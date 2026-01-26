//
//  CyclePanelView.swift
//  Reef
//
//  Window switcher panel UI
//

import SwiftUI

struct CyclePanelView: View {
    @ObservedObject var state: CyclePanelState
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text(state.applicationTitle)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, -12)
                .padding(.bottom, 12)
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Window list
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(Array(state.windows.enumerated()), id: \.element.id) { index, window in
                            CyclePanelRow(
                                title: window.title,
                                isSelected: index == state.selectedIndex
                            )
                            .id(index)
                        }
                    }
                    .padding(8)
                }
                .onChange(of: state.selectedIndex) {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        proxy.scrollTo(state.selectedIndex, anchor: .center)
                    }
                }
            }
        }
        .frame(width: 400)
        .background(Color.clear)
    }
}

struct CyclePanelRow: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection indicator
            Circle()
                .fill(isSelected ? Color.accentColor : Color.clear)
                .frame(width: 6, height: 6)
            
            Text(title)
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(1)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.3) : Color.clear)
        )
    }
}
