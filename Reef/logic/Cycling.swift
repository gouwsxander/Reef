//
//  Cycling.swift
//  Reef
//
//  Created by Xander Gouws on 22-01-2026.
//

import Foundation

class Cycling {
    let application: Application
    let windows: [Window]
    var index: Int
    
    init(_ application: Application, _ index: Int) {
        self.application = application
        self.windows = application.getWindows()
        self.index = index
        
        print(windows)
    }
    
    func next() {
        self.index = (self.index + 1) % windows.count
    }
    
    func getWindow() -> Window {
        return self.windows[self.index]
    }
}

class CycleManager {
    static var cycle: Cycling?
    
    static func setCycle(application: Application, index: Int) {
        cycle = Cycling(application, index)
    }
    
    static func resetCycle() {
        cycle = nil
    }
}
