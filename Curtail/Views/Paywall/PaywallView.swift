import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    Image(systemName: "water.waves")
                        .font(.system(size: 48))
                        .foregroundStyle(CurtailTheme.wave)
                    Text("Curtail Pro")
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .foregroundStyle(CurtailTheme.textHi)

                    VStack(alignment: .leading, spacing: 12) {
                        featureRow("infinity", "Unlimited profiles & unlimited SOS coach talks")
                        featureRow("camera.viewfinder", "30 food label scans per month")
                        featureRow("newspaper.fill", "4 AI weekly insight reports per month")
                        featureRow("applewatch", "Apple Watch wrist SOS")
                        featureRow("square.grid.2x2", "Lock-screen widgets & Live Activity")
                        featureRow("paintpalette.fill", "Themes")
                    }
                    .card()

                    if purchaseManager.products.isEmpty {
                        if purchaseManager.isLoading {
                            ProgressView()
                        } else {
                            Text(purchaseManager.loadError ?? "Subscriptions are unavailable in this build.")
                                .font(.caption)
                                .foregroundStyle(CurtailTheme.textMid)
                        }
                    } else {
                        ForEach(purchaseManager.products.sorted { lhs, rhs in
                            lhs.id == PurchaseManager.yearlyID && rhs.id != PurchaseManager.yearlyID
                        }) { product in
                            subscriptionButton(product)
                        }
                    }

                    Link("Restore purchases / Manage subscription", destination: URL(string: "itms-apps://apps.apple.com/account/subscriptions")!)
                        .font(.caption)
                        .foregroundStyle(CurtailTheme.wave)
                    Button("Restore purchases") {
                        Task { await purchaseManager.restorePurchases() }
                    }
                    .font(.caption)

                    HStack(spacing: 16) {
                        Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/Curtail/privacy.html")!)
                            .font(.caption2)
                            .foregroundStyle(CurtailTheme.wave)
                        Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/Curtail/terms.html")!)
                            .font(.caption2)
                            .foregroundStyle(CurtailTheme.wave)
                    }
                    .padding(.top, 4)

                    Text("Free 7-day trial on both plans. Subscriptions auto-renew unless canceled at least 24 hours before the end of the current period. Manage or cancel anytime in Settings.")
                        .font(.caption2)
                        .foregroundStyle(CurtailTheme.textMid)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
            }
            .background(CurtailTheme.ink)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(CurtailTheme.coral)
                .frame(width: 26)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(CurtailTheme.textHi)
        }
    }

    private func subscriptionButton(_ product: Product) -> some View {
        Button {
            Task {
                let success = await purchaseManager.purchase(product)
                if success { dismiss() }
            }
        } label: {
            VStack(spacing: 4) {
                Text(product.id == PurchaseManager.yearlyID ? "Pro Annual — $29.99/year (7-day free trial)" : "Pro Monthly — $4.99/month (7-day free trial)")
                    .font(.headline)
                Text(product.id == PurchaseManager.yearlyID ? "Best value — save 50%" : "For short-term focus")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.borderedProminent)
        .tint(product.id == PurchaseManager.yearlyID ? CurtailTheme.coral : CurtailTheme.wave)
        .accessibilityLabel("Subscribe to \(product.displayName)")
    }
}
