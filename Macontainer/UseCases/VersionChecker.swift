//
//  VersionChecker.swift
//  Macontainer
//
//  Created by Petr Pavlik on 16.06.2025.
//

import Foundation

struct VersionCheckResult {
    let currentVersion: String
    let latestVersion: String
    let hasNewerVersion: Bool
}

struct VersionChecker {

    static func checkForUpdates(currentVersion: String) async throws -> VersionCheckResult {
        let parsedCurrentVersion = parseVersion(from: currentVersion)
        let latestVersion = try await fetchLatestVersion()

        let hasNewerVersion = compareVersions(current: parsedCurrentVersion, latest: latestVersion)

        if hasNewerVersion {
            print("🔄 Update available!")
            print("   Current version: \(parsedCurrentVersion)")
            print("   Latest version: \(latestVersion)")
            print("   Run: brew update && brew upgrade container")
        } else {
            print("✅ CLI is up to date (\(parsedCurrentVersion))")
        }

        return VersionCheckResult(
            currentVersion: parsedCurrentVersion,
            latestVersion: latestVersion,
            hasNewerVersion: hasNewerVersion
        )
    }

    private static func fetchLatestVersion() async throws -> String {
        guard let url = URL(string: "https://api.github.com/repos/apple/container/releases/latest")
        else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
        return release.tagName
    }

    private static func compareVersions(current: String, latest: String) -> Bool {
        // Clean version strings (remove 'v' prefix if present)
        let cleanCurrent = current.hasPrefix("v") ? String(current.dropFirst()) : current
        let cleanLatest = latest.hasPrefix("v") ? String(latest.dropFirst()) : latest

        return cleanCurrent != cleanLatest
    }

    private static func parseVersion(from versionString: String) -> String {
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

        // Fallback: if regex doesn't match, return the original string
        return versionString
    }
}
