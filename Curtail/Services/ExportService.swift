import Foundation
import SwiftData

enum ExportService {
    static func exportJSON(profiles: [SubstanceProfile]) -> Data? {
        let payload: [[String: Any]] = profiles.map { p in
            [
                "name": p.name,
                "icon": p.icon,
                "mode": p.mode.rawValue,
                "createdAt": p.createdAt.timeIntervalSince1970,
                "currentLapStart": p.currentLapStart.timeIntervalSince1970,
                "longestCleanSeconds": p.longestCleanSeconds,
                "totalRiddenCravings": p.totalRiddenCravings,
                "totalCleanSecondsEver": p.totalCleanSecondsEver,
                "events": (p.events ?? []).map { e in
                    [
                        "kind": e.kind.rawValue,
                        "timestamp": e.timestamp.timeIntervalSince1970,
                        "intensityBefore": e.intensityBefore as Any,
                        "intensityAfter": e.intensityAfter as Any,
                        "quantity": e.quantity as Any,
                        "emotionTag": e.emotionTag as Any,
                        "placeTag": e.placeTag as Any,
                        "note": e.note as Any
                    ] as [String: Any]
                }
            ]
        }
        return try? JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
    }

    static func exportCSV(profiles: [SubstanceProfile]) -> String {
        var rows = ["profile,kind,timestamp,intensity_before,intensity_after,quantity,emotion,place,note"]
        let formatter = ISO8601DateFormatter()
        for p in profiles {
            for e in (p.events ?? []).sorted(by: { $0.timestamp < $1.timestamp }) {
                let fields = [
                    p.name,
                    e.kind.rawValue,
                    formatter.string(from: e.timestamp),
                    e.intensityBefore.map { String($0) } ?? "",
                    e.intensityAfter.map { String($0) } ?? "",
                    e.quantity.map { String($0) } ?? "",
                    e.emotionTag ?? "",
                    e.placeTag ?? "",
                    (e.note ?? "").replacingOccurrences(of: ",", with: " ")
                ]
                rows.append(fields.joined(separator: ","))
            }
        }
        return rows.joined(separator: "\n")
    }
}
