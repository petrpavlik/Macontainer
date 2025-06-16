//
//  Image.swift
//  Macontainer
//
//  Created by Petr Pavlik on 16.06.2025.
//

import Foundation

struct Image: Identifiable {
    var id: String {
        name + ":" + tag + "@" + digest
    }
    var name: String
    var tag: String
    var digest: String
}
