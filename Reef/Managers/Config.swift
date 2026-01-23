//
//  Config.swift
//  Reef
//
//  Created by Xander Gouws on 18-09-2025.
//

import Foundation
import Cocoa
import SwiftData


//@Model
class Config {
    @Attribute(.unique) var name: String
    var bindings: [Application?]
    var appMap: [String: Int]
    var lastUsedDate: Date?
    
    init(_ name: String) {
        self.name = name
        
        self.bindings = Array(repeating: nil, count: 10)
        self.appMap = [:]
        
        self.lastUsedDate = Date.now
    }
    
    @discardableResult
    func bind(_ application: Application, _ index: Int) -> Bool {
        guard let bundleIdentifier = application.runningApplication.bundleIdentifier else {
            return false
        }

        if let currentIndex = appMap[bundleIdentifier] {
            bindings[currentIndex] = nil
        }

        bindings[index] = application
        appMap[bundleIdentifier] = index
        return true
    }
    
    func unbind(bundleIdentifier: String) {
        if let index = appMap[bundleIdentifier] {
            bindings[index] = nil
            appMap[bundleIdentifier] = nil
        }
    }
}


@MainActor
class ConfigManager {
    static private var _config: Config?
    
    static var config: Config {
        if let _config {
            return _config
        }
        
        _config = Config("Default") // loadConfig()
        return _config!
    }
    
//    private static func loadConfig() -> Config {
//        guard let configContainer = try? ModelContainer(for: Config.self) else {
//            print("Couldn't make ModelContainer")
//            return Config("Default")
//        }
//        
//        let context = configContainer.mainContext
//        
//        var recentConfig = FetchDescriptor<Config>(
//            sortBy: [
//                .init(\.lastUsedDate, order: .reverse),
//            ]
//        )
//        recentConfig.fetchLimit = 1
//        
//        if let result = try? context.fetch(recentConfig),
//           let config = result.first {
//            print("Loaded config")
//            return config
//        }
//        
//        print("Created new config")
//        let config = Config("Default")
//        context.insert(config)
//        
//        return config
//    }
}

