import Foundation

enum CrisisDetector {
    static let hotlineNumber = "988"
    static let hotlineName = "988 Suicide & Crisis Lifeline"

    private static let keywords: [String] = [
        "kill myself", "end my life", "want to die", "suicide", "suicidal",
        "self harm", "self-harm", "cut myself", "hurt myself", "no reason to live",
        "better off dead", "end it all"
    ]

    static func isCrisis(_ text: String) -> Bool {
        let lower = text.lowercased()
        return keywords.contains { lower.contains($0) }
    }
}
