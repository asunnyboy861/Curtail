import SwiftData
import Foundation

enum ProfileMode: String, Codable, CaseIterable {
    case abstinence
    case taper
}

@Model
final class SubstanceProfile {
    var id: UUID = UUID()
    var name: String = ""
    var icon: String = "leaf.fill"
    var mode: ProfileMode = ProfileMode.abstinence
    var createdAt: Date = Date()
    var currentLapStart: Date = Date()
    var longestCleanSeconds: TimeInterval = 0
    var totalRiddenCravings: Int = 0
    var totalCleanSecondsEver: TimeInterval = 0
    var gardenSeed: Int = Int.random(in: 0...999)
    var isHidden: Bool = false
    @Relationship(deleteRule: .cascade, inverse: \LifeEvent.profile) var events: [LifeEvent]? = []

    init(name: String, icon: String, mode: ProfileMode, lapStart: Date = Date.now) {
        self.name = name
        self.icon = icon
        self.mode = mode
        self.createdAt = Date.now
        self.currentLapStart = lapStart
    }
}

enum EventKind: String, Codable {
    case cravingRidden, slip, pledge, checkIn
}

@Model
final class LifeEvent {
    var id: UUID = UUID()
    var kind: EventKind = EventKind.checkIn
    var timestamp: Date = Date()
    var intensityBefore: Int?
    var intensityAfter: Int?
    var durationSeconds: Double?
    var quantity: Double?
    var emotionTag: String?
    var placeTag: String?
    var note: String?
    var editedAt: Date?
    var profile: SubstanceProfile?

    init(kind: EventKind, timestamp: Date = Date.now, profile: SubstanceProfile? = nil) {
        self.kind = kind
        self.timestamp = timestamp
        self.profile = profile
    }
}
