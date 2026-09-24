import Foundation

struct RadarBucket: Identifiable {
    let id: Int
    let weekday: Int
    let hourSlot: Int
    var count: Int
    static let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    static let slots = ["Morning", "Afternoon", "Evening", "Night"]
}

struct EmotionCount: Identifiable {
    var id: String { emotion }
    let emotion: String
    var count: Int
}

enum TriggerRadar {
    static func buckets(events: [LifeEvent]) -> [RadarBucket] {
        var grid = Array(repeating: 0, count: 28)
        let calendar = Calendar.current
        for event in events where event.kind == .cravingRidden || event.kind == .slip {
            let weekday = calendar.component(.weekday, from: event.timestamp) - 1
            let hour = calendar.component(.hour, from: event.timestamp)
            let slot = hour < 6 ? 3 : hour < 12 ? 0 : hour < 18 ? 1 : 2
            grid[weekday * 4 + slot] += 1
        }
        return grid.enumerated().map { idx, count in
            RadarBucket(id: idx, weekday: idx / 4, hourSlot: idx % 4, count: count)
        }
    }

    static func topEmotions(events: [LifeEvent], limit: Int = 3) -> [EmotionCount] {
        var counts: [String: Int] = [:]
        for event in events {
            if let e = event.emotionTag, !e.isEmpty { counts[e, default: 0] += 1 }
        }
        return counts.sorted { $0.value > $1.value }.prefix(limit).map { EmotionCount(emotion: $0.key, count: $0.value) }
    }

    static func aggregateStats(profile: SubstanceProfile, events: [LifeEvent]) -> String {
        let buckets = buckets(events: events).filter { $0.count > 0 }
        let grid = buckets.map { ["w": $0.weekday, "s": $0.hourSlot, "n": $0.count] }
        let emotions = topEmotions(events: events).map { ["emotion": $0.emotion, "count": $0.count] }
        let intensities = events.compactMap { $0.intensityBefore }
        let avg = intensities.isEmpty ? 0 : intensities.reduce(0, +) / intensities.count
        let stats: [String: Any] = [
            "riddenCount": profile.totalRiddenCravings,
            "slipCount": events.filter { $0.kind == .slip }.count,
            "avgIntensityBefore": avg,
            "timeslotGrid": grid,
            "topEmotions": emotions
        ]
        if let data = try? JSONSerialization.data(withJSONObject: stats), let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "{}"
    }
}
