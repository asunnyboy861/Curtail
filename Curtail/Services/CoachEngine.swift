import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, *)
@Generable
struct CoachTurn {
    @Guide(description: "One short empathetic sentence, max 12 words, zero judgment, zero shame")
    var empathy: String
    @Guide(description: "One concrete urge-surfing instruction, max 15 words")
    var instruction: String
    @Guide(description: "true if user should be praised for checking in")
    var isPositive: Bool
}

@available(iOS 26.0, *)
@MainActor
final class FMCoachSession {
    private var session: LanguageModelSession?

    func prepare() {
        session = LanguageModelSession(instructions: """
        You are a calm, warm craving-surfing coach. Rules:
        - NEVER mention streaks, days, failure, relapse, guilt.
        - If the user mentions self-harm or crisis, tell them to call or text 988 immediately.
        - Techniques allowed: urge surfing, box breathing, 5-4-3-2-1 grounding, delayed gratification, urge = wave metaphor.
        - Keep each reply under 30 words total. English only.
        """)
    }

    func reply(to userText: String) async -> CoachTurn {
        guard let session else { return Self.templateFallback() }
        do {
            return try await session.respond(to: userText, generating: CoachTurn.self).content
        } catch {
            return Self.templateFallback()
        }
    }

    static func templateFallback() -> CoachTurn {
        CoachTurn(
            empathy: "This wave is real. So is your seat on the board.",
            instruction: "Breathe in 4, hold 4, out 6 — three rounds. I'm timing with you.",
            isPositive: true
        )
    }
}
#endif

struct SimpleCoachTurn {
    let empathy: String
    let instruction: String
    let isPositive: Bool
}

@MainActor
final class CoachEngine {
    static let shared = CoachEngine()

    #if canImport(FoundationModels)
    private var fmSession: Any?
    #endif

    var isOnDeviceAIAvailable: Bool {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) { return true }
        #endif
        return false
    }

    func prepare() {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if fmSession == nil {
                let s = FMCoachSession()
                s.prepare()
                fmSession = s
            }
        }
        #endif
    }

    func reply(to userText: String) async -> SimpleCoachTurn {
        if CrisisDetector.isCrisis(userText) {
            return SimpleCoachTurn(
                empathy: "What you're feeling matters. You don't have to carry this alone.",
                instruction: "Please call or text 988 right now — someone is there 24/7.",
                isPositive: true
            )
        }
        #if canImport(FoundationModels)
        if #available(iOS 26.0, *) {
            if let fm = fmSession as? FMCoachSession {
                let turn = await fm.reply(to: userText)
                return SimpleCoachTurn(empathy: turn.empathy, instruction: turn.instruction, isPositive: turn.isPositive)
            }
        }
        #endif
        return Self.templateFallback(userText)
    }

    static func shameFreeSlipResponse(quantity: Double, emotion: String?) -> SimpleCoachTurn {
        SimpleCoachTurn(
            empathy: "Chapter closed. Nothing was lost — your record stands.",
            instruction: emotion.map { "Next time \($0) shows up, open the SOS pod before it opens for you." }
                ?? "Next time the urge hits, ride the wave first — 20 minutes is all it takes.",
            isPositive: true
        )
    }

    static func dailyInsight(seed: Int) -> String {
        let insights = [
            "Cravings peak, then pass. You only have to outlast the peak.",
            "Every wave you ride rewires the one that follows.",
            "You don't have to be perfect. You just have to keep chapters open.",
            "The urge is loud because it's temporary.",
            "Small surfs today, calmer seas tomorrow.",
            "Your garden grows in the minutes you don't give in.",
            "Notice the trigger, name it, and it loses half its power."
        ]
        return insights[abs(seed) % insights.count]
    }

    private static func templateFallback(_ userText: String) -> SimpleCoachTurn {
        let lower = userText.lowercased()
        if lower.contains("stress") || lower.contains("anxious") || lower.contains("worried") {
            return SimpleCoachTurn(
                empathy: "Stress makes waves taller. You're still standing.",
                instruction: "Try 5-4-3-2-1: name 5 things you see, 4 you feel, 3 you hear.",
                isPositive: true
            )
        }
        if lower.contains("bored") {
            return SimpleCoachTurn(
                empathy: "Boredom is just a wave with bad marketing.",
                instruction: "Stand up and change rooms — motion breaks the loop.",
                isPositive: true
            )
        }
        let pack = [
            SimpleCoachTurn(empathy: "You showed up. That's the hard part.", instruction: "Breathe in 4, hold 4, out 6 — three rounds.", isPositive: true),
            SimpleCoachTurn(empathy: "This wave will pass. It always does.", instruction: "Picture the wave rising, peaking, and falling away.", isPositive: true),
            SimpleCoachTurn(empathy: "Urges are waves, not commands.", instruction: "Ride it out for 20 minutes — I'm here the whole way.", isPositive: true),
            SimpleCoachTurn(empathy: "Strong wave. Stronger surfer.", instruction: "Unclench your jaw, drop your shoulders, breathe out slowly.", isPositive: true),
            SimpleCoachTurn(empathy: "Checking in is already a win.", instruction: "Sip some water and take ten slow breaths with me.", isPositive: true)
        ]
        return pack[abs(userText.hashValue) % pack.count]
    }
}
