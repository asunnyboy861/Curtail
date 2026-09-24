import SwiftUI
import SwiftData

struct SlipBackfillView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var profiles: [SubstanceProfile]
    @State private var quantity: Double = 1
    @State private var when: Date = .now.addingTimeInterval(-3600)
    @State private var emotion = "stress"
    @State private var place = "home"
    @State private var aiResponse: SimpleCoachTurn?
    @State private var addToRadar = true
    @State private var showCrisis = false

    let emotions = ["stress", "bored", "social", "tired", "celebration", "habit"]
    let places = ["home", "work", "out", "car"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Chapter closed. Nothing was lost.")
                        .font(.system(.title3, design: .rounded).bold())
                        .foregroundStyle(CurtailTheme.textHi)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("How much?")
                            .font(.caption).foregroundStyle(CurtailTheme.textMid)
                        HStack {
                            Text(String(format: "%.1f", quantity))
                                .font(.title2.bold().monospacedDigit())
                                .foregroundStyle(CurtailTheme.wave)
                            Slider(value: $quantity, in: 0.5...10, step: 0.5)
                        }
                    }
                    .card()

                    VStack(alignment: .leading, spacing: 10) {
                        Text("When?")
                            .font(.caption).foregroundStyle(CurtailTheme.textMid)
                        DatePicker("When", selection: $when)
                    }
                    .card()

                    tagPicker(title: "How did it feel?", options: emotions, selection: $emotion)
                    tagPicker(title: "Where?", options: places, selection: $place)

                    Toggle("Add to Trigger Radar", isOn: $addToRadar)
                        .tint(CurtailTheme.mint)
                        .foregroundStyle(CurtailTheme.textHi)

                    if let turn = aiResponse {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(turn.empathy)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(CurtailTheme.mint)
                            Text(turn.instruction)
                                .font(.caption)
                                .foregroundStyle(CurtailTheme.textHi)
                        }
                        .card()
                    }

                    Button {
                        saveSlip()
                    } label: {
                        Text("Save data point").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(CurtailTheme.wave)
                }
                .padding(20)
                .frame(maxWidth: 720)
                .frame(maxWidth: .infinity)
            }
            .background(CurtailTheme.ink)
            .navigationTitle("Log a slip")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("If you're in crisis", isPresented: $showCrisis) {
                Button("Call 988") { if let url = URL(string: "tel://988") { UIApplication.shared.open(url) } }
                Button("Not now", role: .cancel) {}
            } message: {
                Text("You don't have to carry this alone. The 988 Suicide & Crisis Lifeline is available 24/7.")
            }
        }
    }

    private func tagPicker(title: String, options: [String], selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.caption).foregroundStyle(CurtailTheme.textMid)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(options, id: \.self) { opt in
                        Button {
                            selection.wrappedValue = opt
                        } label: {
                            Text(opt.capitalized)
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule().fill(selection.wrappedValue == opt ? CurtailTheme.wave.opacity(0.3) : CurtailTheme.surface)
                                )
                                .foregroundStyle(selection.wrappedValue == opt ? CurtailTheme.wave : CurtailTheme.textMid)
                        }
                    }
                }
            }
        }
        .card()
    }

    private func saveSlip() {
        guard let profile = profiles.first else { dismiss(); return }
        let event = LifeEvent(kind: .slip, timestamp: when, profile: profile)
        event.quantity = quantity
        event.emotionTag = emotion
        event.placeTag = place
        if StreakMath.isBackfillMarked(eventDate: when) { event.editedAt = .now }
        context.insert(event)
        StreakMath.applySlip(to: profile, at: when, context: context)
        aiResponse = CoachEngine.shameFreeSlipResponse(quantity: quantity, emotion: emotion)
    }
}
