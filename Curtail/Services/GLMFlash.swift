import Foundation

struct LabelScanResult: Codable {
    struct SugarHit: Codable { let name: String; let aliases: [String] }
    let productGuess: String
    let hiddenSugars: [SugarHit]
    let totalSugarAliasesFound: Int
    let severity: String
    let confidence: Double
    let oneLineAdvice: String
}

struct WeeklyReportResult: Codable {
    let headline: String
    let patterns: [String]
    let nextWeekStrategy: String
}

enum GLMFlash {
    static let defaultEndpoint = "https://api.z.ai/api/paas/v4/chat/completions"
    static let defaultModel = "glm-5.3-flash"

    struct Profile {
        let apiKey: String
        let endpoint: String
        let model: String
    }

    static func loadProfile() -> Profile? {
        guard let url = Bundle.main.url(forResource: "GLMSecret", withExtension: "txt"),
              let raw = try? String(contentsOf: url, encoding: .utf8) else { return nil }
        for line in raw.split(separator: "\n") {
            let line = line.trimmingCharacters(in: .whitespaces)
            if line.isEmpty || line.hasPrefix("#") { continue }
            let parts = line.split(separator: "|").map { String($0).trimmingCharacters(in: .whitespaces) }
            if parts.count >= 3, !parts[0].isEmpty {
                return Profile(apiKey: parts[0], endpoint: parts[1], model: parts[2])
            }
        }
        return nil
    }

    static var isConfigured: Bool { loadProfile() != nil }

    private static func request(profile: Profile, body: [String: Any]) async throws -> String {
        var req = URLRequest(url: URL(string: profile.endpoint)!)
        req.httpMethod = "POST"
        req.timeoutInterval = 60
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(profile.apiKey)", forHTTPHeaderField: "Authorization")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: req)
        let raw = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let choices = raw?["choices"] as? [[String: Any]] ?? []
        return (choices.first?["message"] as? [String: Any])?["content"] as? String ?? "{}"
    }

    private static func decode<T: Decodable>(_ text: String) throws -> T {
        let jsonStr = String(text.drop { $0 != "{" })
        return try JSONDecoder().decode(T.self, from: Data(jsonStr.utf8))
    }

    static func scanFoodLabel(imageJPEG: Data, addiction: String) async throws -> LabelScanResult {
        guard let profile = loadProfile() else { throw GLMError.notConfigured }
        let b64 = imageJPEG.base64EncodedString()
        let body: [String: Any] = [
            "model": profile.model,
            "temperature": 1, "top_p": 0.95,
            "messages": [[
                "role": "user",
                "content": [
                    ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(b64)"]],
                    ["type": "text", "text": """
                    This is a US food/beverage nutrition label photo. User is quitting \(addiction).
                    1) Identify product. 2) List EVERY sugar alias in ingredients (sucrose, dextrose, maltose, maltodextrin, corn syrup, high-fructose corn syrup, fruit juice concentrate, cane juice, molasses, honey, agave, rice syrup, evaporated cane juice, barley malt, dextrin, and similar).
                    3) Rate severity for someone quitting sugar. 4) Give one-line advice.
                    Respond ONLY as JSON: {"productGuess":"","hiddenSugars":[{"name":"","aliases":[]}],"totalSugarAliasesFound":0,"severity":"low|medium|high","confidence":0.0,"oneLineAdvice":""}
                    """]
                ]
            ]]
        ]
        let content = try await request(profile: profile, body: body)
        return try decode(content)
    }

    static func weeklyReport(stats: String) async throws -> WeeklyReportResult {
        guard let profile = loadProfile() else { throw GLMError.notConfigured }
        let body: [String: Any] = [
            "model": profile.model,
            "temperature": 1, "top_p": 0.95,
            "messages": [[
                "role": "user",
                "content": """
                You are a shame-free craving coach analyzing ANONYMOUS aggregate statistics for someone reducing an habit.
                Stats JSON: \(stats)
                Identify 2-3 trigger patterns (weekday x timeslot x emotion) and give one concrete next-week strategy.
                NEVER use words: relapse, failed, reset, guilt, shame.
                Respond ONLY as JSON: {"headline":"","patterns":["",""],"nextWeekStrategy":""}
                """
            ]]
        ]
        let content = try await request(profile: profile, body: body)
        return try decode(content)
    }
}

enum GLMError: LocalizedError {
    case notConfigured
    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Cloud AI is not configured on this device build."
        }
    }
}
