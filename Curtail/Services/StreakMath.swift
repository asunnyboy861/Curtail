import Foundation
import SwiftData

enum StreakMath {
    static func lapDuration(_ p: SubstanceProfile, now: Date = .now) -> TimeInterval {
        now.timeIntervalSince(p.currentLapStart)
    }

    @MainActor
    static func applySlip(to p: SubstanceProfile, at date: Date = .now, context: ModelContext) {
        let lapLen = date.timeIntervalSince(p.currentLapStart)
        p.totalCleanSecondsEver += max(0, lapLen)
        p.longestCleanSeconds = max(p.longestCleanSeconds, lapLen)
        p.currentLapStart = date
        try? context.save()
    }

    @MainActor
    static func applyRiddenCraving(to p: SubstanceProfile, context: ModelContext) {
        p.totalRiddenCravings += 1
        try? context.save()
    }

    static func isBackfillMarked(eventDate: Date, now: Date = .now) -> Bool {
        now.timeIntervalSince(eventDate) > 7 * 86400
    }

    static func formatDuration(_ seconds: TimeInterval) -> String {
        let d = Int(seconds / 86400)
        let h = Int(seconds.truncatingRemainder(dividingBy: 86400) / 3600)
        let m = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
        if d > 0 { return "\(d)d \(h)h" }
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}
