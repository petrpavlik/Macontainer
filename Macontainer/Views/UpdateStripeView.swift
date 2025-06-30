//
//  UpdateStripeView.swift
//  Macontainer
//
//  Created by Petr Pavlik on 30.06.2025.
//

#if canImport(SwiftUI)
import SwiftUI

struct UpdateStripeView: View {
    let currentVersion: String
    let latestVersion: String
    let onUpdateAction: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.up.circle.fill")
                .foregroundColor(.blue)
            
            Text("A new version of Macontainer is available")
                .font(.subheadline)
            
            Text("(\(latestVersion))")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Update") {
                onUpdateAction()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

#Preview {
    UpdateStripeView(
        currentVersion: "1.0.0",
        latestVersion: "1.1.0",
        onUpdateAction: {}
    )
}
#endif