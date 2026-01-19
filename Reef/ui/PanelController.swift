//
//  PanelController.swift
//  Reef
//
//  Created by Xander Gouws on 19-01-2026.
//

import AppKit
import SwiftUI

@MainActor
class PanelController: NSObject {
    var panel: NSPanel!
    
    override init() {
        super.init()
        createPanel()
    }
    
    func createPanel() {
        let contentRect = NSRect(x: 0, y: 0, width: 400, height: 300)
        panel = Panel(contentRect: contentRect)
        
        let contentView = PanelUI()
        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = contentRect
        
        panel.contentView?.addSubview(hostingView)
        
        panel.center()
    }
}
