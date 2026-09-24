import SwiftUI
import SwiftData

struct WeeklyReportView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [SubstanceProfile]
    @State private var isLoading = false
    @State private var report: WeeklyReportResult?
    @State private var errorMessage: String?
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let report {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(report.headline)
                            .font(.system(.title3, design: .rounded).bold())
                            .foregroundStyle(CurtailTheme.mint)
                        ForEach(report.patterns, id: \.self) { pattern in
                            Label(pattern, systemImage: "scope")
                                .font(.subheadline)
                                .foregroundStyle(CurtailTheme.textHi)
                        }
                        Text("Next week")
                            .font(.caption)
                            .foregroundStyle(CurtailTheme.textMid)
                        Text(report.nextWeekStrategy)
                            .font(.subheadline)
                            .foregroundStyle(CurtailTheme.textHi)
                    }
                    .card()
                } else if isLoading {
                    ProgressView("Thinking about your week…")
                        .foregroundStyle(CurtailTheme.textMid)
                } else {
                    Image(systemName: "newspaper.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(CurtailTheme.wave)
                    Text("Your AI weekly report reads your trigger patterns and plans next week with you.")
                        .foregroundStyle(CurtailTheme.textMid)
                        .multilineTextAlignment(.center)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(CurtailTheme.coral)
                        .multilineTextAlignment(.center)
                }

                if PurchaseManager.shared.isPro {
                    Button {
                        generateReport()
                    } label: {
                        Label("Generate this week's report", systemImage: "wand.and.stars")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button {
                        showPaywall = true
                    } label: {
                        Label("Weekly reports are Pro", systemImage: "lock.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(20)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(CurtailTheme.ink)
        .navigationTitle("Weekly report")
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private func generateReport() {
        guard let profile = profiles.first else { return }
        let used = QuotaStore.monthlyCount("weeklyReports")
        guard used < QuotaStore.proReportsPerMonth else {
            errorMessage = "Monthly quota reached (4 reports). Resets on the 1st."
            return
        }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let stats = TriggerRadar.aggregateStats(profile: profile, events: profile.events ?? [])
                let result = try await GLMFlash.weeklyReport(stats: stats)
                await MainActor.run {
                    report = result
                    QuotaStore.incrementMonthly("weeklyReports")
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
}
