//
//  MacontainerVersionViewModel.swift
//  Macontainer
//
//  Created by Petr Pavlik on 30.06.2025.
//

import Foundation

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
                
                // Parse versions and compare
                let currentParsed = parseVersion(from: currentVersionString)
                let latestParsed = parseVersion(from: latestVersionString)
                
                self.isNewVersionAvailable = compareVersions(current: currentParsed, latest: latestParsed)
                
                if isNewVersionAvailable {
                    print("🔄 Update available!")
                    print("   Current version: \(currentParsed)")
                    print("   Latest version: \(latestParsed)")
                } else {
                    print("✅ Macontainer is up to date (\(currentParsed))")
                }
            } catch {
                print("Failed to check for updates: \(error)")
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
    
    private func compareVersions(current: String, latest: String) -> Bool {
        // Split versions into components
        let currentComponents = current.split(separator: ".").compactMap { Int($0) }
        let latestComponents = latest.split(separator: ".").compactMap { Int($0) }
        
        // Ensure we have at least 3 components for both versions
        guard currentComponents.count >= 3, latestComponents.count >= 3 else {
            // Fallback to string comparison if parsing fails
            return current != latest
        }
        
        // Compare major, minor, patch versions
        for i in 0..<3 {
            if latestComponents[i] > currentComponents[i] {
                return true
            } else if latestComponents[i] < currentComponents[i] {
                return false
            }
        }
        
        return false // Versions are equal
    }
    
    func openReleasesPage() {
#if canImport(AppKit)
        if let url = URL(string: "https://github.com/petrpavlik/Macontainer/releases") {
            NSWorkspace.shared.open(url)
        }
#endif
    }
}