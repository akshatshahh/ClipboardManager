//
//  ClipboardEntry.swift
//  Clipboard Manager
//
//  Created by Akshat on 22/06/25.
//
import Foundation

struct ClipboardEntry: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    var text: String
    var pinned: Bool = false

    init(id: UUID = UUID(), text: String, pinned: Bool = false) {
        self.id = id
        self.text = text
        self.pinned = pinned
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
