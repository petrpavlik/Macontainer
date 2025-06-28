//
//  CommandRunner.swift
//  Macontainer
//
//  Created by Petr Pavlik on 16.06.2025.
//

import Foundation
import os.log

private let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "com.macontainer", category: "CommandRunner")

@discardableResult
func runCommand(_ command: String, arguments: [String] = []) -> String? {
    let fullCommand = "\(command) \(arguments.joined(separator: " "))"
    logger.debug("Executing command: \(fullCommand)")

    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
    } catch {
        logger.error("Failed to run command '\(fullCommand)': \(error.localizedDescription)")
        print("Failed to run command: \(error)")
        return nil
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let result = String(data: data, encoding: .utf8)

    if let result = result {
        logger.debug("Command '\(fullCommand)' returned: \(result)")
    } else {
        logger.debug("Command '\(fullCommand)' returned no output")
    }

    return result
}
