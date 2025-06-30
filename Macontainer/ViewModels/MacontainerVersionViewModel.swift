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
        // Initialize current version from the container CLI
        getCurrentVersion()
    }
    
    func setWindowActive(_ active: Bool) {
        if active {
            checkForUpdatesIfNeeded()
        }
    }
    
    private func getCurrentVersion() {
        // Get the current version from the container CLI
        let containerCommandPath = "/usr/local/bin/container"
        currentVersion = runCommand(containerCommandPath, arguments: ["--version"])?.trimmingCharacters(
            in: .whitespacesAndNewlines)
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
                
                // Parse versions and compare using SemverComparator
                let currentParsed = parseVersion(from: currentVersionString)
                let latestParsed = latestVersionString
                
                self.isNewVersionAvailable = SemverComparator.isGreaterThan(latestParsed, currentParsed)
                
                if isNewVersionAvailable {
                    logger.info("🔄 Update available!")
                    logger.info("   Current version: \(currentParsed)")
                    logger.info("   Latest version: \(latestParsed)")
                } else {
                    logger.info("✅ Macontainer is up to date (\(currentParsed))")
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
    
    private func parseVersion(from versionString: String) -> String {
        // Handle format like "container CLI version 0.1.0 (build: release, commit: 0fd8692)"
        let pattern = #"version\s+(\d+\.\d+\.\d+)"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(
               in: versionString, options: [],
               range: NSRange(location: 0, length: versionString.utf16.count)),
           let range = Range(match.range(at: 1), in: versionString)
        {
            return String(versionString[range])
        }
        
        // For release tags, they might be in format "v1.2.3" or "1.2.3"
        let cleanVersion = versionString.hasPrefix("v") ? String(versionString.dropFirst()) : versionString
        
        // Check if it's already a clean version number
        let versionPattern = #"^\d+\.\d+\.\d+$"#
        if let regex = try? NSRegularExpression(pattern: versionPattern, options: []),
           regex.firstMatch(in: cleanVersion, options: [], range: NSRange(location: 0, length: cleanVersion.utf16.count)) != nil {
            return cleanVersion
        }
        
        // Fallback: return the original string
        return versionString
    }
    
    func openReleasesPage() {
#if canImport(AppKit)
        if let url = URL(string: "https://github.com/petrpavlik/Macontainer/releases") {
            NSWorkspace.shared.open(url)
        }
#endif
    }
}