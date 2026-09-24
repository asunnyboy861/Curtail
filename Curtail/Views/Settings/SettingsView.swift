import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [SubstanceProfile]
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showPaywall = false
    @State private var exportURL: URL?

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Version \(version) (\(build))"
    }

    var body: some View {
        Form {
            Section("Subscription") {
                if purchaseManager.isPro {
                    Label("Curtail Pro is active", systemImage: "checkmark.seal.fill")
                        .foregroundStyle(CurtailTheme.mint)
                } else {
                    Button {
                        showPaywall = true
                    } label: {
                        Label("Upgrade to Pro", systemImage: "crown.fill")
                    }
                }
                Button {
                    Task { await purchaseManager.restorePurchases() }
                } label: {
                    Label("Restore purchases", systemImage: "arrow.clockwise")
                }
                Link(destination: URL(string: "itms-apps://apps.apple.com/account/subscriptions")!) {
                    Label("Manage subscription — cancel in 2 taps", systemImage: "creditcard")
                }
            }

            Section("Data") {
                Button {
                    exportData(asJSON: true)
                } label: {
                    Label("Export as JSON", systemImage: "square.and.arrow.up")
                }
                Button {
                    exportData(asJSON: false)
                } label: {
                    Label("Export as CSV", systemImage: "tablecells")
                }
            }

            Section("Notifications") {
                Button {
                    Task {
                        if await NotificationScheduler.requestAuthorization() {
                            NotificationScheduler.scheduleEveningCheckIn()
                        }
                    }
                } label: {
                    Label("Evening check-in reminder", systemImage: "bell")
                }
                Button(role: .destructive) {
                    NotificationScheduler.cancelAll()
                } label: {
                    Label("Turn off all reminders", systemImage: "bell.slash")
                }
            }

            Section("About") {
                Link(destination: URL(string: "https://asunnyboy861.github.io/Curtail/support.html")!) {
                    Label("Contact Support", systemImage: "bubble.left")
                }
                NavigationLink(destination: ContactSupportView()) {
                    Label("Send feedback", systemImage: "envelope")
                }
                Link(destination: URL(string: "https://asunnyboy861.github.io/Curtail/privacy.html")!) {
                    Label("Privacy Policy", systemImage: "hand.raised")
                }
                Link(destination: URL(string: "https://asunnyboy861.github.io/Curtail/terms.html")!) {
                    Label("Terms of Use", systemImage: "doc.text")
                }
            }

            Section {
                Text("Curtail is a self-help tool, not medical treatment. For substance dependence, consult a professional.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(appVersion)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showPaywall) { PaywallView() }
        .sheet(item: Binding(
            get: { exportURL.map { ExportURL(url: $0) } },
            set: { exportURL = $0?.url }
        )) { item in
            ActivitySheet(url: item.url)
        }
    }

    private func exportData(asJSON: Bool) {
        let data = asJSON ? ExportService.exportJSON(profiles: profiles) : ExportService.exportCSV(profiles: profiles).data(using: .utf8)
        let ext = asJSON ? "json" : "csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("curtail-export.\(ext)")
        try? data?.write(to: url)
        exportURL = url
    }
}

struct ExportURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct ActivitySheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
