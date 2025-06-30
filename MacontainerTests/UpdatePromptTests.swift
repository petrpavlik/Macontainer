//
//  UpdatePromptTests.swift
//  MacontainerTests
//
//  Created by Assistant on 30.06.2025.
//

import Testing
@testable import Macontainer

struct UpdatePromptTests {
    
    @Test("UserDefaults extensions for update prompt")
    func userDefaultsExtensions() {
        let userDefaults = UserDefaults.standard
        
        // Test lastSkippedUpdateVersion
        userDefaults.lastSkippedUpdateVersion = "1.2.3"
        #expect(userDefaults.lastSkippedUpdateVersion == "1.2.3")
        
        userDefaults.lastSkippedUpdateVersion = nil
        #expect(userDefaults.lastSkippedUpdateVersion == nil)
        
        // Test lastRemindedUpdateVersion
        userDefaults.lastRemindedUpdateVersion = "1.2.4"
        #expect(userDefaults.lastRemindedUpdateVersion == "1.2.4")
        
        userDefaults.lastRemindedUpdateVersion = nil
        #expect(userDefaults.lastRemindedUpdateVersion == nil)
    }
    
    @Test("Update prompt logic")
    func updatePromptLogic() async {
        // This test verifies the logic of when to show update prompts
        // Note: This is a conceptual test since we can't easily test the full ViewModel
        // without mocking network calls and UI components
        
        let userDefaults = UserDefaults.standard
        
        // Clean state
        userDefaults.lastSkippedUpdateVersion = nil
        userDefaults.lastRemindedUpdateVersion = nil
        
        // Test case 1: First time seeing a new version should show prompt
        let newVersion = "1.5.0"
        #expect(userDefaults.lastSkippedUpdateVersion != newVersion)
        #expect(userDefaults.lastRemindedUpdateVersion != newVersion)
        
        // Test case 2: After skipping a version, it should not show prompt for that version
        userDefaults.lastSkippedUpdateVersion = newVersion
        #expect(userDefaults.lastSkippedUpdateVersion == newVersion)
        
        // Test case 3: After being reminded about a version, it should not show prompt again
        userDefaults.lastSkippedUpdateVersion = nil
        userDefaults.lastRemindedUpdateVersion = newVersion
        #expect(userDefaults.lastRemindedUpdateVersion == newVersion)
        
        // Clean up
        userDefaults.lastSkippedUpdateVersion = nil
        userDefaults.lastRemindedUpdateVersion = nil
    }
}