//
//  AXUIElement.swift
//  Reef
//
//  Created by Xander Gouws on 16-09-2025.
//

import Foundation
import Cocoa

extension AXUIElement {
    func getValue<T>(_ attribute: NSAccessibility.Attribute) -> T? {
        var value: AnyObject?
        
        let result = AXUIElementCopyAttributeValue(self, attribute.rawValue as CFString, &value)
        
        guard result == .success else {
            print(result.rawValue)
            return nil
        }
       
        return value as? T
    }
    
    func performAction(_ action: NSAccessibility.Action) throws(AXError) {
        let result = AXUIElementPerformAction(self, action.rawValue as CFString)
        
        guard result == .success else {
            print(result.rawValue)
            throw result
        }
    }
    
    func getId() -> CGWindowID? {
        var windowID = CGWindowID(0)
        
        let result = _AXUIElementGetWindow(self, &windowID)
        
        guard result == .success else {
            print(result.rawValue)
            return nil
        }
        
        return windowID
    }
}

@_silgen_name("_AXUIElementGetWindow") @discardableResult
func _AXUIElementGetWindow(_ axUiElement: AXUIElement, _ wid: UnsafeMutablePointer<CGWindowID>) -> AXError

@_silgen_name("GetProcessForPID") @discardableResult
func GetProcessForPID(_ pid: pid_t, _ psn: UnsafeMutablePointer<ProcessSerialNumber>) -> OSStatus

extension AXError: @retroactive Error {}
