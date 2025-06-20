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
        // FIXME: This does not work, at least on my machine.
        if let path = runCommand("/usr/bin/which", arguments: ["container"])?.trimmingCharacters(in: .whitespacesAndNewlines), !path.isEmpty {
            containerCommandPath = path
        }
        
        cliVersion = runCommand(containerCommandPath, arguments: ["--version"])?.trimmingCharacters(in: .whitespacesAndNewlines)
        updateImages()
        updateContainers()
        updateSystemStatus()
        
        // Check if containers should be launched on app launch
        if UserDefaults.standard.launchContainersOnAppLaunch {
            // Start system (which will start containers)
            if !isSystemRunning {
                startSystem()
            }
        }
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
    
    private func updateContainers() {
        let output = runCommand(containerCommandPath, arguments: ["list", "--all"])
        guard let output = output else { return }
        
        let lines = output.split(separator: "\n").dropFirst() // Skip header line
        containers = lines.map { line in
            let parts = line.split(separator: " ", maxSplits: 5, omittingEmptySubsequences: true)
            return Container(
                id: String(parts[0]),
                image: String(parts[1]),
                os: String(parts[2]),
                arch: String(parts[3]),
                state: String(parts[4]),
                addr: parts.count > 5 ? String(parts[5]) : ""
            )
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
        updateImages()
        shouldPresentAlert = true
    }
    
    func deleteAllImages() {
        alertTitle = "All Images Deleted"
        alertMessage = runCommand(containerCommandPath, arguments: ["image", "delete", "--all"]) ?? ""
        if alertMessage.isEmpty {
            alertMessage = "All images have been deleted."
        }
        updateImages()
        shouldPresentAlert = true
    }
    
    func deleteAllContainers() {
        alertTitle = "All Containers Deleted"
        alertMessage = runCommand(containerCommandPath, arguments: ["delete", "--all"]) ?? ""
        if alertMessage.isEmpty {
            alertMessage = "All containers have been deleted."
        }
        updateContainers()
        shouldPresentAlert = true
    }
    
    func deleteSelectedImages(_ selectedIds: Set<String>) {
        alertTitle = selectedIds.count == 1 ? "Image Deleted" :  "\(selectedIds.count) Images Deleted"
        alertMessage = ""
        for imageId in selectedIds {
            if let image = images.first(where: { $0.id == imageId }) {
                alertMessage += runCommand(containerCommandPath, arguments: ["image", "delete", "\(image.name):\(image.tag)"]) ?? ""
                alertMessage += "\n\n"
            }
        }
        updateImages()
        shouldPresentAlert = true
    }
    
    func deleteSelectedContainers(_ selectedIds: Set<String>) {
        alertTitle = selectedIds.count == 1 ? "Container Deleted" : "\(selectedIds.count) Containers Deleted"
        alertMessage = ""
        for containerId in selectedIds {
            alertMessage += runCommand(containerCommandPath, arguments: ["delete", containerId]) ?? ""
            alertMessage += "\n\n"
        }
        updateContainers()
        shouldPresentAlert = true
    }
    
    func startSelectedContainers(_ selectedIds: Set<String>) {
        alertTitle = selectedIds.count == 1 ? "Container Started" : "\(selectedIds.count) Containers Started"
        alertMessage = ""
        for containerId in selectedIds {
            alertMessage += runCommand(containerCommandPath, arguments: ["start", containerId]) ?? ""
            alertMessage += "\n\n"
        }
        updateContainers()
        shouldPresentAlert = true
    }
    
    func stopSelectedContainers(_ selectedIds: Set<String>) {
        alertTitle = selectedIds.count == 1 ? "Container Stopped" : "\(selectedIds.count) Containers Stopped"
        alertMessage = ""
        for containerId in selectedIds {
            alertMessage += runCommand(containerCommandPath, arguments: ["stop", containerId]) ?? ""
            alertMessage += "\n\n"
        }
        updateContainers()
        shouldPresentAlert = true
    }
    
    func killSelectedContainers(_ selectedIds: Set<String>) {
        alertTitle = selectedIds.count == 1 ? "Container Killed" : "\(selectedIds.count) Containers Killed"
        alertMessage = ""
        for containerId in selectedIds {
            alertMessage += runCommand(containerCommandPath, arguments: ["kill", containerId]) ?? ""
            alertMessage += "\n\n"
        }
        updateContainers()
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
    
    func shutdown() {
        // Check if containers should be quit on app quit
        if UserDefaults.standard.quitContainersOnAppQuit {
            if isSystemRunning {
                print("Stopping container system before app shutdown...")
                stopSystem()
            }
        }
    }
}

struct ContentView: View {
    
    enum ListItemSelection {
        case containers
        case images
        case settings
    }
    
    @State private var viewModel = ViewModel()
    @State private var listItemSelection: ListItemSelection = .containers
    @State private var selectedImageIds = Set<String>()
    @State private var selectedContainerIds = Set<String>()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack {
            NavigationSplitView {
                List(selection: $listItemSelection) {
                    NavigationLink(value: ListItemSelection.containers) {
                        Label("Containers", systemImage: "shippingbox")
                    }.contextMenu {
                        Button("Delete all") {
                            viewModel.deleteAllContainers()
                        }
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
                    NavigationLink(value: ListItemSelection.settings) {
                        Label("Settings", systemImage: "gearshape")
                    }
                }
                .navigationTitle("Menu")
            } detail: {
                VStack {
                    switch listItemSelection {
                    case .containers:
                        Table(viewModel.containers, selection: $selectedContainerIds) {
                            TableColumn("ID", value: \.id)
                            TableColumn("Image", value: \.image)
                            TableColumn("OS", value: \.os)
                            TableColumn("Arch", value: \.arch)
                            TableColumn("State", value: \.state)
                            TableColumn("Address", value: \.addr)
                        }
                        .onDeleteCommand {
                            if !selectedContainerIds.isEmpty {
                                viewModel.deleteSelectedContainers(selectedContainerIds)
                            }
                        }
                        .contextMenu {
                            if !selectedContainerIds.isEmpty {
                                Button(selectedContainerIds.count > 1 ? "Start (\(selectedContainerIds.count))" : "Start") {
                                    viewModel.startSelectedContainers(selectedContainerIds)
                                }
                                Button(selectedContainerIds.count > 1 ? "Stop (\(selectedContainerIds.count))" : "Stop") {
                                    viewModel.stopSelectedContainers(selectedContainerIds)
                                }
                                Button(selectedContainerIds.count > 1 ? "Kill (\(selectedContainerIds.count))" : "Kill") {
                                    viewModel.killSelectedContainers(selectedContainerIds)
                                }
                                Divider()
                                Button(selectedContainerIds.count > 1 ? "Delete (\(selectedContainerIds.count))" : "Delete") {
                                    viewModel.deleteSelectedContainers(selectedContainerIds)
                                }
                            }
                        }
                    case .images:
                        Table(viewModel.images, selection: $selectedImageIds) {
                            TableColumn("Name", value: \.name)
                            TableColumn("Tag", value: \.tag)
                            TableColumn("Digest", value:\.digest)
                        }
                        .onDeleteCommand {
                            if !selectedImageIds.isEmpty {
                                viewModel.deleteSelectedImages(selectedImageIds)
                            }
                        }
                        .contextMenu {
                            if (selectedImageIds.isEmpty == false) {
                                Button(selectedImageIds.count > 1 ? "Delete (\(selectedImageIds.count))" : "Delete") {
                                    viewModel.deleteSelectedImages(selectedImageIds)
                                }
                            }
                        }
                    case .settings:
                        SettingsView()
                    }
                }
            }
            .toolbar {
                HStack {
                    Text(viewModel.cliVersion ?? "Unknown version")
                        .foregroundColor(viewModel.hasNewerVersion ? .orange : .secondary)
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
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            viewModel.shutdown()
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
