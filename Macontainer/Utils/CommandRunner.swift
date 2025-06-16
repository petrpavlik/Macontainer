//
//  CommandRunner.swift
//  Macontainer
//
//  Created by Petr Pavlik on 16.06.2025.
//

import Foundation

@discardableResult
func runCommand(_ command: String, arguments: [String] = []) -> String? {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: command)
    process.arguments = arguments

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = pipe

    do {
        try process.run()
    } catch {
        print("Failed to run command: \(error)")
        return nil
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)
}
