//
//  Panel.swift
//  Reef
//
//  Created by Xander Gouws on 19-01-2026.
//

import AppKit
import SwiftUI

final class Panel: NSPanel, NSWindowDelegate {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.titled, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        self.hasShadow = true
        self.level = .floating
        self.collectionBehavior.insert(.fullScreenAuxiliary)
        self.collectionBehavior.insert(.canJoinAllSpaces)
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovable = false
        self.isMovableByWindowBackground = false
        self.isReleasedWhenClosed = false
        self.isOpaque = false
        self.delegate = self
        self.backgroundColor = .clear
        self.hidesOnDeactivate = true
        
        let effectView = NSVisualEffectView(frame: .zero)
        effectView.autoresizingMask = [.width, .height]
        effectView.material = .hudWindow
        effectView.blendingMode = .behindWindow
        effectView.state = .active
        
        self.contentView = effectView
    }
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
    
    func windowDidResignKey(_ notification: Notification) {
        self.orderOut(nil)
    }
}
