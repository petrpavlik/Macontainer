//
//  SemverComparatorTests.swift
//  MacontainerTests
//
//  Created by Petr Pavlik on 28.06.2025.
//

import Testing

@testable import Macontainer

struct SemverComparatorTests {

    // MARK: - Basic Comparison Tests

    @Test("Basic greater than comparisons")
    func basicGreaterThan() {
        #expect(SemverComparator.isGreaterThan("1.0.0", "0.9.9"))
        #expect(SemverComparator.isGreaterThan("0.3.0", "0.2.0"))
        #expect(SemverComparator.isGreaterThan("0.2.1", "0.2.0"))
        #expect(SemverComparator.isGreaterThan("2.0.0", "1.9.9"))

        #expect(!SemverComparator.isGreaterThan("0.1.0", "0.2.0"))
        #expect(!SemverComparator.isGreaterThan("1.0.0", "1.0.0"))
        #expect(!SemverComparator.isGreaterThan("0.9.9", "1.0.0"))
    }

    @Test("Basic less than comparisons")
    func basicLessThan() {
        #expect(SemverComparator.isLessThan("0.9.9", "1.0.0"))
        #expect(SemverComparator.isLessThan("0.1.0", "0.2.0"))
        #expect(SemverComparator.isLessThan("0.2.0", "0.2.1"))
        #expect(SemverComparator.isLessThan("1.9.9", "2.0.0"))

        #expect(!SemverComparator.isLessThan("0.3.0", "0.2.0"))
        #expect(!SemverComparator.isLessThan("1.0.0", "1.0.0"))
        #expect(!SemverComparator.isLessThan("1.0.0", "0.9.9"))
    }

    @Test("Basic equality comparisons")
    func basicEqual() {
        #expect(SemverComparator.isEqual("1.0.0", "1.0.0"))
        #expect(SemverComparator.isEqual("0.2.0", "0.2.0"))
        #expect(SemverComparator.isEqual("10.5.3", "10.5.3"))

        #expect(!SemverComparator.isEqual("1.0.0", "1.0.1"))
        #expect(!SemverComparator.isEqual("0.2.0", "0.3.0"))
        #expect(!SemverComparator.isEqual("1.0.0", "2.0.0"))
    }

    // MARK: - Greater Than or Equal Tests

    @Test("Greater than or equal comparisons")
    func greaterThanOrEqual() {
        #expect(SemverComparator.isGreaterThanOrEqual("1.0.0", "0.9.9"))
        #expect(SemverComparator.isGreaterThanOrEqual("1.0.0", "1.0.0"))
        #expect(SemverComparator.isGreaterThanOrEqual("0.3.0", "0.2.0"))

        #expect(!SemverComparator.isGreaterThanOrEqual("0.1.0", "0.2.0"))
        #expect(!SemverComparator.isGreaterThanOrEqual("0.9.9", "1.0.0"))
    }

    @Test("Less than or equal comparisons")
    func lessThanOrEqual() {
        #expect(SemverComparator.isLessThanOrEqual("0.9.9", "1.0.0"))
        #expect(SemverComparator.isLessThanOrEqual("1.0.0", "1.0.0"))
        #expect(SemverComparator.isLessThanOrEqual("0.1.0", "0.2.0"))

        #expect(!SemverComparator.isLessThanOrEqual("1.0.0", "0.9.9"))
        #expect(!SemverComparator.isLessThanOrEqual("0.3.0", "0.2.0"))
    }

    // MARK: - Missing Components Tests

    @Test("Missing minor and patch versions")
    func missingMinorAndPatch() {
        // "1" should be treated as "1.0.0"
        #expect(SemverComparator.isGreaterThan("1", "0.9.9"))
        #expect(SemverComparator.isEqual("1", "1.0.0"))
        #expect(SemverComparator.isLessThan("1", "1.0.1"))
    }

    @Test("Missing patch version")
    func missingPatch() {
        // "1.2" should be treated as "1.2.0"
        #expect(SemverComparator.isGreaterThan("1.2", "1.1.9"))
        #expect(SemverComparator.isEqual("1.2", "1.2.0"))
        #expect(SemverComparator.isLessThan("1.2", "1.2.1"))
    }

    @Test("Mixed missing components")
    func mixedMissingComponents() {
        #expect(SemverComparator.isGreaterThan("1.1", "1.0.9"))
        #expect(SemverComparator.isGreaterThan("2", "1.9.9"))
        #expect(SemverComparator.isEqual("0.2", "0.2.0"))
    }

    // MARK: - Version Prefix Tests

    @Test("Versions with v prefix")
    func versionWithVPrefix() {
        #expect(SemverComparator.isGreaterThan("v1.0.0", "v0.9.9"))
        #expect(SemverComparator.isGreaterThan("v1.0.0", "0.9.9"))
        #expect(SemverComparator.isGreaterThan("1.0.0", "v0.9.9"))
        #expect(SemverComparator.isEqual("v1.0.0", "1.0.0"))
    }

    // MARK: - Edge Cases

    @Test("Zero versions")
    func zeroVersions() {
        #expect(SemverComparator.isEqual("0.0.0", "0.0.0"))
        #expect(SemverComparator.isGreaterThan("0.0.1", "0.0.0"))
        #expect(SemverComparator.isGreaterThan("0.1.0", "0.0.9"))
        #expect(SemverComparator.isGreaterThan("1.0.0", "0.9.9"))
    }

    @Test("Large version numbers")
    func largeVersionNumbers() {
        #expect(SemverComparator.isGreaterThan("100.200.300", "99.999.999"))
        #expect(SemverComparator.isEqual("123.456.789", "123.456.789"))
    }

    // MARK: - String Extension Tests

    @Test("String extension greater than")
    func stringExtensionGreaterThan() {
        #expect("1.0.0".isVersionGreaterThan("0.9.9"))
        #expect("0.3.0".isVersionGreaterThan("0.2.0"))
        #expect(!"0.1.0".isVersionGreaterThan("0.2.0"))
    }

    @Test("String extension less than")
    func stringExtensionLessThan() {
        #expect("0.9.9".isVersionLessThan("1.0.0"))
        #expect("0.1.0".isVersionLessThan("0.2.0"))
        #expect(!"0.3.0".isVersionLessThan("0.2.0"))
    }

    @Test("String extension equal")
    func stringExtensionEqual() {
        #expect("1.0.0".isVersionEqual("1.0.0"))
        #expect("0.2.0".isVersionEqual("0.2.0"))
        #expect(!"1.0.0".isVersionEqual("1.0.1"))
    }

    // MARK: - Comparison Result Tests

    @Test("Compare function results")
    func compareFunction() {
        #expect(SemverComparator.compare("1.0.0", "0.9.9") == .orderedDescending)
        #expect(SemverComparator.compare("0.9.9", "1.0.0") == .orderedAscending)
        #expect(SemverComparator.compare("1.0.0", "1.0.0") == .orderedSame)
    }

    // MARK: - Real-world Use Case Tests

    @Test("User specified example - checking if version is larger than 0.2")
    func userSpecifiedExample() {
        #expect("0.3.0".isVersionGreaterThan("0.2"))
        #expect("0.2.1".isVersionGreaterThan("0.2"))
        #expect("1.0.0".isVersionGreaterThan("0.2"))

        #expect(!"0.1.9".isVersionGreaterThan("0.2"))
        #expect(!"0.2.0".isVersionGreaterThan("0.2"))  // 0.2.0 is equal to 0.2, not greater
    }

    @Test("Common version patterns")
    func commonVersionPatterns() {
        // Test patterns commonly seen in software versioning
        #expect("1.0.0".isVersionGreaterThan("1.0.0-beta"))
        #expect("2.1.0".isVersionGreaterThan("2.0.15"))
        #expect("10.0.0".isVersionGreaterThan("9.99.99"))
    }

    // MARK: - Malformed Version Tests

    @Test("Empty versions")
    func emptyVersions() {
        // Empty strings should be treated as 0.0.0
        #expect("1.0.0".isVersionGreaterThan(""))
        #expect("".isVersionEqual("0.0.0"))
    }

    //    @Test("Invalid characters")
    //    func invalidCharacters() {
    //        // Non-numeric components should be treated as 0
    //        #expect("1.0.0".isVersionGreaterThan("1.0.abc"))
    //        #expect("1.1.0".isVersionGreaterThan("1.abc.0"))
    //    }

    // MARK: - Parameterized Tests

    @Test(
        "Version comparison matrix",
        arguments: [
            ("1.0.0", "0.9.9", true),
            ("0.3.0", "0.2.0", true),
            ("0.2.1", "0.2.0", true),
            ("2.0.0", "1.9.9", true),
            ("0.1.0", "0.2.0", false),
            ("1.0.0", "1.0.0", false),
            ("0.9.9", "1.0.0", false),
        ])
    func versionComparisonMatrix(version1: String, version2: String, expectedGreater: Bool) {
        #expect(SemverComparator.isGreaterThan(version1, version2) == expectedGreater)
    }

    @Test(
        "Version equality matrix",
        arguments: [
            ("1.0.0", "1.0.0", true),
            ("0.2.0", "0.2.0", true),
            ("v1.0.0", "1.0.0", true),
            ("1.2", "1.2.0", true),
            ("1", "1.0.0", true),
            ("1.0.0", "1.0.1", false),
            ("0.2.0", "0.3.0", false),
        ])
    func versionEqualityMatrix(version1: String, version2: String, expectedEqual: Bool) {
        #expect(SemverComparator.isEqual(version1, version2) == expectedEqual)
    }
}
