//
//  SemverComparator.swift
//  Macontainer
//
//  Created by Petr Pavlik on 28.06.2025.
//

import Foundation

struct SemverComparator {

    /// Compares two semantic version strings
    /// - Parameters:
    ///   - version1: First version string (e.g., "1.2.3")
    ///   - version2: Second version string (e.g., "0.2.0")
    /// - Returns: ComparisonResult indicating if version1 is less than, equal to, or greater than version2
    static func compare(_ version1: String, _ version2: String) -> ComparisonResult {
        let v1Components = parseVersion(version1)
        let v2Components = parseVersion(version2)

        // Compare major version
        if v1Components.major != v2Components.major {
            return v1Components.major < v2Components.major ? .orderedAscending : .orderedDescending
        }

        // Compare minor version
        if v1Components.minor != v2Components.minor {
            return v1Components.minor < v2Components.minor ? .orderedAscending : .orderedDescending
        }

        // Compare patch version
        if v1Components.patch != v2Components.patch {
            return v1Components.patch < v2Components.patch ? .orderedAscending : .orderedDescending
        }

        // If base versions are equal, check for pre-release suffixes
        // A version without suffix is greater than one with suffix (e.g., "1.0.0" > "1.0.0-beta")
        let v1HasSuffix = hasPreReleaseSuffix(version1)
        let v2HasSuffix = hasPreReleaseSuffix(version2)

        if v1HasSuffix && !v2HasSuffix {
            return .orderedAscending  // v1 has suffix, v2 doesn't, so v1 < v2
        } else if !v1HasSuffix && v2HasSuffix {
            return .orderedDescending  // v1 doesn't have suffix, v2 does, so v1 > v2
        }

        return .orderedSame
    }

    private static func hasPreReleaseSuffix(_ version: String) -> Bool {
        let cleanVersion = version.hasPrefix("v") ? String(version.dropFirst()) : version
        return cleanVersion.contains("-")
    }

    /// Checks if version1 is greater than version2
    /// - Parameters:
    ///   - version1: First version string
    ///   - version2: Second version string
    /// - Returns: True if version1 > version2
    static func isGreaterThan(_ version1: String, _ version2: String) -> Bool {
        return compare(version1, version2) == .orderedDescending
    }

    /// Checks if version1 is less than version2
    /// - Parameters:
    ///   - version1: First version string
    ///   - version2: Second version string
    /// - Returns: True if version1 < version2
    static func isLessThan(_ version1: String, _ version2: String) -> Bool {
        return compare(version1, version2) == .orderedAscending
    }

    /// Checks if version1 is equal to version2
    /// - Parameters:
    ///   - version1: First version string
    ///   - version2: Second version string
    /// - Returns: True if version1 == version2
    static func isEqual(_ version1: String, _ version2: String) -> Bool {
        return compare(version1, version2) == .orderedSame
    }

    /// Checks if version1 is greater than or equal to version2
    /// - Parameters:
    ///   - version1: First version string
    ///   - version2: Second version string
    /// - Returns: True if version1 >= version2
    static func isGreaterThanOrEqual(_ version1: String, _ version2: String) -> Bool {
        let result = compare(version1, version2)
        return result == .orderedDescending || result == .orderedSame
    }

    /// Checks if version1 is less than or equal to version2
    /// - Parameters:
    ///   - version1: First version string
    ///   - version2: Second version string
    /// - Returns: True if version1 <= version2
    static func isLessThanOrEqual(_ version1: String, _ version2: String) -> Bool {
        let result = compare(version1, version2)
        return result == .orderedAscending || result == .orderedSame
    }

    private static func parseVersion(_ version: String) -> (major: Int, minor: Int, patch: Int) {
        // Remove 'v' prefix if present
        let cleanVersion = version.hasPrefix("v") ? String(version.dropFirst()) : version

        // Handle pre-release versions by removing suffixes like "-beta", "-alpha", etc.
        let versionWithoutSuffix =
            cleanVersion.split(separator: "-").first.map(String.init) ?? cleanVersion

        // Split by dots and parse components
        let components = versionWithoutSuffix.split(separator: ".").map { component in
            // Try to parse as Int, if it fails (e.g., "abc"), return 0
            Int(component) ?? 0
        }

        let major = components.count > 0 ? components[0] : 0
        let minor = components.count > 1 ? components[1] : 0
        let patch = components.count > 2 ? components[2] : 0

        return (major: major, minor: minor, patch: patch)
    }
}

// MARK: - Convenience Extensions
extension String {
    /// Checks if this version string is greater than the specified version
    /// - Parameter other: Version to compare against
    /// - Returns: True if this version > other version
    func isVersionGreaterThan(_ other: String) -> Bool {
        return SemverComparator.isGreaterThan(self, other)
    }

    /// Checks if this version string is less than the specified version
    /// - Parameter other: Version to compare against
    /// - Returns: True if this version < other version
    func isVersionLessThan(_ other: String) -> Bool {
        return SemverComparator.isLessThan(self, other)
    }

    /// Checks if this version string is equal to the specified version
    /// - Parameter other: Version to compare against
    /// - Returns: True if this version == other version
    func isVersionEqual(_ other: String) -> Bool {
        return SemverComparator.isEqual(self, other)
    }

    /// Checks if this version string is greater than or equal to the specified version
    /// - Parameter other: Version to compare against
    /// - Returns: True if this version >= other version
    func isVersionGreaterThanOrEqual(_ other: String) -> Bool {
        return SemverComparator.isGreaterThanOrEqual(self, other)
    }

    /// Checks if this version string is less than or equal to the specified version
    /// - Parameter other: Version to compare against
    /// - Returns: True if this version <= other version
    func isVersionLessThanOrEqual(_ other: String) -> Bool {
        return SemverComparator.isLessThanOrEqual(self, other)
    }
}
