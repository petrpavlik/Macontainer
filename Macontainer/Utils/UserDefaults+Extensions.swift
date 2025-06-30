//
//  UserDefaults+Extensions.swift
//  Macontainer
//
//  Created by Petr Pavlik on 19.06.2025.
//

import Foundation

extension UserDefaults {
    var launchContainersOnAppLaunch: Bool {
        get {
            return bool(forKey: "launchContainersOnAppLaunch")
        }
        set {
            set(newValue, forKey: "launchContainersOnAppLaunch")
        }
    }

    var quitContainersOnAppQuit: Bool {
        get {
            return bool(forKey: "quitContainersOnAppQuit")
        }
        set {
            set(newValue, forKey: "quitContainersOnAppQuit")
        }
    }
    
    var lastSkippedUpdateVersion: String? {
        get {
            return string(forKey: "lastSkippedUpdateVersion")
        }
        set {
            set(newValue, forKey: "lastSkippedUpdateVersion")
        }
    }
    
    var lastRemindedUpdateVersion: String? {
        get {
            return string(forKey: "lastRemindedUpdateVersion")
        }
        set {
            set(newValue, forKey: "lastRemindedUpdateVersion")
        }
    }
}
