//
//  SettingsView.swift
//  Macontainer
//
//  Created by Petr Pavlik on 19.06.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("launchContainersOnAppLaunch") private var launchContainersOnAppLaunch: Bool = false
    @AppStorage("quitContainersOnAppQuit") private var quitContainersOnAppQuit: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)

            GroupBox("Container Management") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Toggle(
                            "Launch Container CLI when app launches",
                            isOn: $launchContainersOnAppLaunch
                        )
                        .help("Automatically start all containers when Macontainer launches")
                        Spacer()
                    }

                    HStack {
                        Toggle("Quit Container CLI when app quits", isOn: $quitContainersOnAppQuit)
                            .help("Automatically stop all containers when Macontainer quits")
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
            }

            Text(
                "These settings control how containers are managed when the application starts and stops."
            )
            .font(.caption)
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
