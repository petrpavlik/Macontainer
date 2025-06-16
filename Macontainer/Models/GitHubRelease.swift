//
//  GitHubRelease.swift
//  Macontainer
//
//  Created by Petr Pavlik on 16.06.2025.
//

import Foundation

// GitHub API response structure
struct GitHubRelease: Codable {
    let tagName: String
    let name: String
    let publishedAt: String
    
    enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case name
        case publishedAt = "published_at"
    }
}
