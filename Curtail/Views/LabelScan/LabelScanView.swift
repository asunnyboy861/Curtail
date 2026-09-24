import SwiftUI
import SwiftData
import PhotosUI

struct LabelScanView: View {
    @Query private var profiles: [SubstanceProfile]
    @State private var photoItem: PhotosPickerItem?
    @State private var isLoading = false
    @State private var result: LabelScanResult?
    @State private var errorMessage: String?
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 44))
                            .foregroundStyle(CurtailTheme.wave)
                        Text("Scan a nutrition label")
                            .font(.headline)
                            .foregroundStyle(CurtailTheme.textHi)
                        Text("Finds hidden sugar aliases the front label hides.")
                            .font(.caption)
                            .foregroundStyle(CurtailTheme.textMid)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 36)
                }
                .buttonStyle(.bordered)
                .tint(CurtailTheme.wave)

                if isLoading { ProgressView("Reading the label…") }

                if let result {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(result.productGuess)
                            .font(.headline)
                            .foregroundStyle(CurtailTheme.textHi)
                        if result.confidence < 0.6 {
                            Text("Low confidence — try retaking the photo in better light.")
                                .font(.caption)
                                .foregroundStyle(CurtailTheme.coral)
                        }
                        ForEach(result.hiddenSugars, id: \.name) { hit in
                            Label(hit.name, systemImage: "exclamationmark.triangle.fill")
                                .font(.subheadline)
                                .foregroundStyle(CurtailTheme.coral)
                        }
                        Text("\(result.totalSugarAliasesFound) sugar aliases · severity: \(result.severity)")
                            .font(.caption)
                            .foregroundStyle(CurtailTheme.textMid)
                        Text(result.oneLineAdvice)
                            .font(.subheadline)
                            .foregroundStyle(CurtailTheme.mint)
                    }
                    .card()
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(CurtailTheme.coral)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(20)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(CurtailTheme.ink)
        .navigationTitle("Label scan")
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            scan(item)
        }
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private func scan(_ item: PhotosPickerItem) {
        let monthlyLimit = PurchaseManager.shared.isPro ? QuotaStore.proScansPerMonth : QuotaStore.freeScansPerMonth
        let used = QuotaStore.monthlyCount("labelScans")
        guard used < monthlyLimit else {
            errorMessage = PurchaseManager.shared.isPro
                ? "Monthly quota reached (30 scans). Resets on the 1st."
                : "Free quota is 2 scans/month. Pro gives you 30."
            if !PurchaseManager.shared.isPro { showPaywall = true }
            return
        }
        errorMessage = nil
        isLoading = true
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data),
                  let jpeg = image.jpegData(compressionQuality: 0.7) else {
                await MainActor.run { isLoading = false; errorMessage = "Could not read that photo." }
                return
            }
            do {
                let addiction = profiles.first?.name ?? "sugar"
                let r = try await GLMFlash.scanFoodLabel(imageJPEG: jpeg, addiction: addiction.lowercased())
                await MainActor.run {
                    result = r
                    QuotaStore.incrementMonthly("labelScans")
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
