import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router
    @Query private var profiles: [SubstanceProfile]
    @State private var showSlipBackfill = false
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let profile = profiles.first {
                    dailyInsightBanner(profile)
                    cravingButton(profile)
                    currentLapSummary(profile)
                    SlipBackfillButton { showSlipBackfill = true }
                }
            }
            .padding(20)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(CurtailTheme.ink)
        .navigationTitle("Curtail")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    NavigationLink(destination: ProfilesView()) { Label("Profiles", systemImage: "square.stack.3d.up") }
                    NavigationLink(destination: LabelScanView()) { Label("Label scan", systemImage: "camera.viewfinder") }
                    NavigationLink(destination: WeeklyReportView()) { Label("Weekly report", systemImage: "newspaper") }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("More features")
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showSlipBackfill) {
            SlipBackfillView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .onAppear {
            if PurchaseManager.shared.isPro == false, shouldShowUpgradeCard() {
                showPaywall = true
                UserDefaults.standard.set(true, forKey: "curtail.paywall.day3.shown")
            }
        }
    }

    private func shouldShowUpgradeCard() -> Bool {
        guard !UserDefaults.standard.bool(forKey: "curtail.paywall.day3.shown") else { return false }
        guard let firstSOSDate = UserDefaults.standard.object(forKey: "curtail.firstSOS") as? Date else { return false }
        return Date.now.timeIntervalSince(firstSOSDate) > 3 * 86400
    }

    private func dailyInsightBanner(_ profile: SubstanceProfile) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.caption)
                .foregroundStyle(CurtailTheme.textMid)
            Text(CoachEngine.dailyInsight(seed: Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0))
                .font(.system(.title3, design: .rounded).weight(.medium))
                .foregroundStyle(CurtailTheme.textHi)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private func cravingButton(_ profile: SubstanceProfile) -> some View {
        Button {
            CoachEngine.shared.prepare()
            router.openSOS()
        } label: {
            HStack {
                Image(systemName: "water.waves")
                    .font(.title2)
                Text("I feel a craving")
                    .font(.system(.title3, design: .rounded).bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 26)
        }
        .buttonStyle(.borderedProminent)
        .tint(CurtailTheme.wave)
        .accessibilityLabel("Start SOS urge surfing session")
    }

    private func currentLapSummary(_ profile: SubstanceProfile) -> some View {
        HStack(spacing: 16) {
            StatPill(label: "This lap", value: StreakMath.formatDuration(StreakMath.lapDuration(profile)), color: CurtailTheme.wave)
            StatPill(label: "Longest ever", value: StreakMath.formatDuration(profile.longestCleanSeconds), color: CurtailTheme.mint)
            StatPill(label: "Ridden", value: "\(profile.totalRiddenCravings)", color: CurtailTheme.coral)
        }
    }
}

struct StatPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.headline, design: .rounded).monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(CurtailTheme.textMid)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface))
    }
}

struct SlipBackfillButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Log a slip — it's just a data point", systemImage: "plus.circle")
                .font(.subheadline)
                .foregroundStyle(CurtailTheme.textMid)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.bordered)
        .accessibilityLabel("Log a slip or data point")
    }
}
