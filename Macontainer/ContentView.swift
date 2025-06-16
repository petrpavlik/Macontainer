//
//  ContentView.swift
//  Macontainer
//
//  Created by Petr Pavlik on 11.06.2025.
//

import SwiftUI

@Observable @MainActor final class ViewModel {
    
    private(set) var cliVersion: String?
    private(set) var latestVersion: String?
    private(set) var hasNewerVersion: Bool = false
    @ObservationIgnored private var isWindowActive: Bool = false
    @ObservationIgnored private var updateTimer: Timer?
    @ObservationIgnored private var containerCommandPath: String = "/usr/local/bin/container"
    
    private(set) var containers: [Container] = []
    private(set) var images: [Image] = []
    private(set) var isSystemRunning: Bool = false
    
    var shouldPresentAlert = false
    @ObservationIgnored private(set) var alertMessage = ""
    @ObservationIgnored private(set) var alertTitle = ""
    
    init() {
        // Find the actual path of the container command
        if let path = runCommand("/usr/bin/which", arguments: ["container"])?.trimmingCharacters(in: .whitespacesAndNewlines), !path.isEmpty {
            containerCommandPath = path
        }
        
        cliVersion = runCommand(containerCommandPath, arguments: ["--version"])?.trimmingCharacters(in: .whitespacesAndNewlines)
        updateImages()
        updateSystemStatus()
    }
    
    func setWindowActive(_ active: Bool) {
        isWindowActive = active
        
        if active {
            // Start periodic updates when window becomes active
            startPeriodicUpdates()
            // Check for updates when window becomes active
            checkForUpdates()
        } else {
            // Stop updates when window becomes inactive
            stopPeriodicUpdates()
        }
    }
    
    private func startPeriodicUpdates() {
        stopPeriodicUpdates() // Ensure we don't have multiple timers
        updateTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            DispatchQueue.main.async {
                self.updateImages()
                self.updateSystemStatus()
            }
        }
    }
    
    private func stopPeriodicUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func checkSystemRunning() -> Bool {
        let output = runCommand(containerCommandPath, arguments: ["list"])
        guard let output = output else { return false }
        if output.contains("XPC connection error") {
            return false
        } else {
            return true
        }
    }
    
    private func updateSystemStatus() {
        isSystemRunning = checkSystemRunning()
    }
    
    private func updateImages() {
        let output = runCommand(containerCommandPath, arguments: ["images", "list"])
        guard let output = output else { return }
        
        let lines = output.split(separator: "\n").dropFirst() // Skip header line
        images = lines.map { line in
            let parts = line.split(separator: " ")
            return Image(name: String(parts[0]), tag: String(parts[1]), digest: String(parts[2]))
        }
    }
    
    func startSystem() {
        runCommand(containerCommandPath, arguments: ["system", "start"])
        // Update status immediately after attempting to start
        updateSystemStatus()
    }
    
    func stopSystem() {
        runCommand(containerCommandPath, arguments: ["system", "stop"])
        // Update status immediately after attempting to stop
        updateSystemStatus()
    }
    
    func pruneImages() {
        alertTitle = "Images Pruned"
        alertMessage = runCommand(containerCommandPath, arguments: ["image", "prune"]) ?? ""
        shouldPresentAlert = true
    }
    
    func deleteAllImages() {
        alertTitle = "All Images Deleted"
        alertMessage = runCommand(containerCommandPath, arguments: ["image", "delete", "--all"]) ?? ""
        if alertMessage.isEmpty {
            alertMessage = "All images have been deleted."
        }
        shouldPresentAlert = true
    }
    
    private func checkForUpdates() {
        guard let currentVersion = cliVersion else { return }
        
        Task {
            do {
                let result = try await VersionChecker.checkForUpdates(currentVersion: currentVersion)
                self.latestVersion = result.latestVersion
                self.hasNewerVersion = result.hasNewerVersion
            } catch {
                print("Failed to check for updates: \(error)")
            }
        }
    }
}

struct ContentView: View {
    
    enum ListItemSelection {
        case containers
        case images
    }
    
    @State private var viewModel = ViewModel()
    @State private var listItemSelection: ListItemSelection = .containers
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack {
            NavigationSplitView {
                List(selection: $listItemSelection) {
                    NavigationLink(value: ListItemSelection.containers) {
                        Label("Containers", systemImage: "shippingbox")
                    }
                    NavigationLink(value: ListItemSelection.images) {
                        Label("Images", systemImage: "opticaldisc")
                    }.contextMenu {
                        Button("Prune") {
                            viewModel.pruneImages()
                        }
                        Button("Delete all") {
                            viewModel.deleteAllImages()
                        }
                    }
                }
                .navigationTitle("Menu")
            } detail: {
                VStack {
                    switch listItemSelection {
                    case .containers:
                        Table(viewModel.containers) {
                            TableColumn("ID", value: \.id)
                            TableColumn("Image", value: \.image)
                            TableColumn("OS", value: \.os)
                            TableColumn("Arch", value: \.arch)
                            TableColumn("State", value: \.state)
                            TableColumn("Address", value: \.addr)
                        }
                    case .images:
                        Table(viewModel.images) {
                            TableColumn("Name", value: \.name)
                            TableColumn("Tag", value: \.tag)
                            TableColumn("Digest", value:\.digest)
                        }
                    }
                    
//                    HStack {
//                        Text("✅ CLI is up to date")
//                    }
                }
            }
            .toolbar {
                HStack {
                    Text(viewModel.cliVersion ?? "Unknown version")
                        .foregroundColor(.secondary)
                    Button(action: {
                        if viewModel.isSystemRunning {
                            viewModel.stopSystem()
                        } else {
                            viewModel.startSystem()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(viewModel.isSystemRunning ? .green : .red)
                                .frame(width: 10, height: 10)
                            Text(viewModel.isSystemRunning ? "Stop" : "Start")
                        }.padding(.horizontal, 4)
                    }
                }
            }
            
            
        }
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.setWindowActive(newPhase == .active)
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.shouldPresentAlert) {
                    Button("OK") {
                        
                    }
                } message: {
                    Text(viewModel.alertMessage)
                }
    }
}

#Preview {
    ContentView()
}
