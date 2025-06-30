//
//  MacontainerVersionViewModel.swift
//  Macontainer
//
//  Created by Petr Pavlik on 30.06.2025.
//

import Foundation
import os.log

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.macontainer", category: "MacontainerVersionViewModel")

@Observable @MainActor final class MacontainerVersionViewModel {
    
    private(set) var isNewVersionAvailable = false
    private(set) var currentVersion: String?
    private(set) var latestVersion: String?
    
    private var lastUpdateCheck: Date?
    private let minimumCheckInterval: TimeInterval = 3600 // 1 hour
    
    init() {
        // Initialize current version from the Macontainer app
        getCurrentVersion()
    }
    
    func setWindowActive(_ active: Bool) {
        if active {
            checkForUpdatesIfNeeded()
        }
    }
    
    private func getCurrentVersion() {
        // Get the current version of Macontainer app
        currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    private func checkForUpdatesIfNeeded() {
        // Check if we need to rate limit the update checks
        if let lastCheck = lastUpdateCheck {
            let timeSinceLastCheck = Date().timeIntervalSince(lastCheck)
            if timeSinceLastCheck < minimumCheckInterval {
                return // Too soon since last check
            }
        }
        
        checkForUpdates()
    }
    
    private func checkForUpdates() {
        guard let currentVersionString = currentVersion else { return }
        
        lastUpdateCheck = Date()
        
        Task {
            do {
                let latestVersionString = try await fetchLatestVersion()
                self.latestVersion = latestVersionString
                
                // Use SemverComparator to compare versions directly
                self.isNewVersionAvailable = SemverComparator.isGreaterThan(latestVersionString, currentVersionString)
                
                if isNewVersionAvailable {
                    logger.info("🔄 Update available!")
                    logger.info("   Current version: \(currentVersionString)")
                    logger.info("   Latest version: \(latestVersionString)")
                } else {
                    logger.info("✅ Macontainer is up to date (\(currentVersionString))")
                }
            } catch {
                logger.error("Failed to check for updates: \(error.localizedDescription)")
            }
        }
    }
    
    private func fetchLatestVersion() async throws -> String {
        guard let url = URL(string: "https://api.github.com/repos/petrpavlik/Macontainer/releases/latest")
        else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
        return release.tagName
    }
    
    func openReleasesPage() {
#if canImport(AppKit)
        if let url = URL(string: "https://github.com/petrpavlik/Macontainer/releases") {
            NSWorkspace.shared.open(url)
        }
#endif
    }
}