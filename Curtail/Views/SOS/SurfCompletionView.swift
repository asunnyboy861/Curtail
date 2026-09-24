import SwiftUI
import SwiftData

struct SurfCompletionView: View {
    @Environment(\.modelContext) private var context
    @State private var intensityAfter = 4
    @State private var showRitual = false
    @State private var saved = false
    let intensityBefore: Int
    let profile: SubstanceProfile?
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "party.popper.fill")
                .font(.system(size: 56))
                .foregroundStyle(CurtailTheme.coral)
            Text("You rode it out. That wave is gone forever.")
                .font(.system(.title2, design: .rounded).bold())
                .foregroundStyle(CurtailTheme.textHi)
                .multilineTextAlignment(.center)
                .card()

            VStack(spacing: 12) {
                Text("Intensity when it hit: \(intensityBefore)")
                    .font(.subheadline)
                    .foregroundStyle(CurtailTheme.textMid)
                HStack {
                    Text("Now?")
                        .foregroundStyle(CurtailTheme.textHi)
                    Slider(value: Binding(
                        get: { Double(intensityAfter) },
                        set: { intensityAfter = Int($0) }
                    ), in: 1...10)
                }
            }
            .card()

            if showRitual {
                RitualCardCarousel()
            } else {
                Button {
                    showRitual = true
                } label: {
                    Label("Try a replacement ritual", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(CurtailTheme.coral)
            }

            Button {
                saveEvent()
                onDone()
            } label: {
                Text("Done").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(24)
    }

    private func saveEvent() {
        guard saved == false else { return }
        saved = true
        guard let profile else { return }
        let event = LifeEvent(kind: .cravingRidden, profile: profile)
        event.intensityBefore = intensityBefore
        event.intensityAfter = intensityAfter
        event.durationSeconds = 20 * 60
        context.insert(event)
        StreakMath.applyRiddenCraving(to: profile, context: context)
    }
}

struct RitualCardCarousel: View {
    let rituals: [(String, String)] = [
        ("figure.pushups", "20 pushups"),
        ("snowflake", "Cold water on your face"),
        ("figure.walk", "10-minute walk"),
        ("leaf.fill", "Chew gum slowly"),
        ("phone.fill", "Text someone who cares")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Replacement ritual")
                .font(.caption)
                .foregroundStyle(CurtailTheme.textMid)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(rituals, id: \.1) { icon, label in
                        VStack(spacing: 8) {
                            Image(systemName: icon)
                                .font(.title3)
                                .foregroundStyle(CurtailTheme.wave)
                            Text(label)
                                .font(.caption)
                                .foregroundStyle(CurtailTheme.textHi)
                                .multilineTextAlignment(.center)
                        }
                        .padding(14)
                        .frame(width: 110)
                        .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface))
                    }
                }
            }
        }
    }
}
