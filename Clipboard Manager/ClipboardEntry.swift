import Foundation

struct ClipboardEntry: Identifiable, Equatable, Codable, Hashable {
    let id: UUID
    var text: String
    var pinned: Bool
    let createdAt: Date

    init(id: UUID = UUID(), text: String, pinned: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.pinned = pinned
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        pinned = try container.decodeIfPresent(Bool.self, forKey: .pinned) ?? false
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var relativeTimestamp: String {
        let interval = Date().timeIntervalSince(createdAt)
        switch interval {
        case ..<5: return "just now"
        case ..<60: return "\(Int(interval))s ago"
        case ..<3600: return "\(Int(interval / 60))m ago"
        case ..<86400: return "\(Int(interval / 3600))h ago"
        default: return "\(Int(interval / 86400))d ago"
        }
    }
}
