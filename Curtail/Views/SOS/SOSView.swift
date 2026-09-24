import SwiftUI
import SwiftData
import ActivityKit

struct SOSView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var profiles: [SubstanceProfile]
    @State private var viewModel = SOSViewModel()

    var body: some View {
        ZStack {
            CurtailTheme.ink.ignoresSafeArea()
            WaveBreathingAnimation(isSurfing: viewModel.isSurfing)

            VStack(spacing: 24) {
                if viewModel.isSurfing {
                    surfingContent
                } else {
                    completionContent
                }
            }
            .padding(24)
        }
        .onAppear {
            viewModel.startSurf()
            recordSessionStart()
        }
        .onDisappear {
            finishLiveActivity()
        }
    }

    private var surfingContent: some View {
        VStack(spacing: 24) {
            Spacer()
            Text(viewModel.formattedRemaining)
                .font(.system(size: 56, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(CurtailTheme.textHi)
            Text("Ride the wave. It passes.")
                .foregroundStyle(CurtailTheme.textMid)
            Spacer()
            coachDrawer
        }
    }

    private var completionContent: some View {
        SurfCompletionView(
            intensityBefore: viewModel.intensityBefore,
            profile: profiles.first
        ) {
            dismiss()
        }
    }

    private var coachDrawer: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.coachMessages, id: \.self) { message in
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(CurtailTheme.textHi)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface.opacity(0.9)))
            }
            if viewModel.coachChatsUsed < viewModel.maxCoachChats {
                HStack(spacing: 10) {
                    TextField("Want to talk about it?", text: $viewModel.userInput, axis: .vertical)
                        .textFieldStyle(.plain)
                        .foregroundStyle(CurtailTheme.textHi)
                        .onSubmit { viewModel.sendToCoach() }
                    Button {
                        viewModel.sendToCoach()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                    .disabled(viewModel.userInput.isEmpty)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface.opacity(0.9)))
            } else {
                Text("Coach rests after \(viewModel.maxCoachChats) talks today — the timer keeps going.")
                    .font(.caption)
                    .foregroundStyle(CurtailTheme.textMid)
            }
        }
    }

    private func recordSessionStart() {
        if UserDefaults.standard.object(forKey: "curtail.firstSOS") == nil {
            UserDefaults.standard.set(Date.now, forKey: "curtail.firstSOS")
        }
        viewModel.startLiveActivity()
    }

    private func finishLiveActivity() {
        viewModel.endLiveActivity()
    }
}

struct WaveBreathingAnimation: View {
    let isSurfing: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let phase = isSurfing ? t : t * 0.4
                for layer in 0..<3 {
                    let amplitude = 18.0 + Double(layer) * 10
                    let speed = 0.9 + Double(layer) * 0.25
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: size.height))
                    for x in stride(from: 0.0, through: size.width, by: 8) {
                        let y = size.height * 0.62
                            + sin((x / size.width) * .pi * 2 + phase * speed + Double(layer)) * amplitude
                            + Double(layer) * 26
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    path.addLine(to: CGPoint(x: size.width, y: size.height))
                    path.addLine(to: CGPoint(x: 0, y: size.height))
                    context.fill(path, with: .color(CurtailTheme.wave.opacity(0.10 + Double(layer) * 0.07)))
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

@MainActor
@Observable
final class SOSViewModel {
    var isSurfing = true
    var remaining: TimeInterval = 20 * 60
    var intensityBefore = 9
    var coachMessages: [String] = []
    var userInput = ""
    var coachChatsUsed = 0
    let maxCoachChats = QuotaStore.freeCoachChatsPerDay

    private var timer: Timer?

    var formattedRemaining: String {
        let m = Int(remaining) / 60
        let s = Int(remaining) % 60
        return String(format: "%d:%02d", m, s)
    }

    func startSurf() {
        remaining = 20 * 60
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.remaining -= 1
                if self.remaining <= 0 { self.completeSurf() }
            }
        }
    }

    func sendToCoach() {
        guard !userInput.isEmpty else { return }
        let text = userInput
        userInput = ""
        if !PurchaseManager.shared.isPro && coachChatsUsed >= QuotaStore.freeCoachChatsPerDay { return }
        coachChatsUsed += 1
        QuotaStore.incrementDaily("coachChats")
        coachMessages.append("You: \(text)")
        Task {
            let turn = await CoachEngine.shared.reply(to: text)
            coachMessages.append("\(turn.empathy) \(turn.instruction)")
        }
    }

    func completeSurf() {
        timer?.invalidate()
        timer = nil
        isSurfing = false
    }

    func startLiveActivity() {
        #if canImport(ActivityKit)
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            let attributes = SurfActivityAttributes(profileName: "Surf")
            let state = SurfActivityAttributes.ContentState(remainingSeconds: 20 * 60)
            LiveActivityHolder.shared.current = try? Activity<SurfActivityAttributes>.request(
                attributes: attributes,
                content: .init(state: state, staleDate: nil)
            )
        }
        #endif
    }

    func endLiveActivity() {
        #if canImport(ActivityKit)
        LiveActivityHolder.shared.endCurrent()
        #endif
    }
}

final class LiveActivityHolder: @unchecked Sendable {
    static let shared = LiveActivityHolder()
    var current: Any?

    func endCurrent() {
        guard let liveActivity = current as? Activity<SurfActivityAttributes> else {
            current = nil
            return
        }
        current = nil
        let state = SurfActivityAttributes.ContentState(remainingSeconds: 0)
        Task {
            await liveActivity.end(
                ActivityContent(state: state, staleDate: nil),
                dismissalPolicy: .immediate
            )
        }
    }
}

