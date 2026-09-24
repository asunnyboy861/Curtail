import SwiftUI
import SwiftData

struct GardenView: View {
    @Query private var profiles: [SubstanceProfile]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let profile = profiles.first {
                    Text("Your garden")
                        .font(.system(.title2, design: .rounded).bold())
                        .foregroundStyle(CurtailTheme.textHi)

                    GardenCanvas(plants: GardenEngine.plants(for: profile))
                        .frame(height: 320)
                        .background(RoundedRectangle(cornerRadius: 20).fill(CurtailTheme.surface))
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    HStack(spacing: 16) {
                        StatPill(label: "Growth", value: "\(GardenEngine.growthLevel(for: profile))%", color: CurtailTheme.mint)
                        StatPill(label: "Ridden", value: "\(profile.totalRiddenCravings)", color: CurtailTheme.coral)
                        StatPill(label: "Longest", value: StreakMath.formatDuration(profile.longestCleanSeconds), color: CurtailTheme.wave)
                    }

                    Button {
                        shareCard(profile: profile)
                    } label: {
                        Label("Share progress card", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(CurtailTheme.mint)
                }
            }
            .padding(20)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(CurtailTheme.ink)
        .navigationTitle("Garden")
    }

    private func shareCard(profile: SubstanceProfile) {
        let text = "Curtail — Longest: \(StreakMath.formatDuration(profile.longestCleanSeconds)) | This lap: \(StreakMath.formatDuration(StreakMath.lapDuration(profile))) | Waves ridden: \(profile.totalRiddenCravings). Nothing resets. Nothing lost."
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
           let root = scene.keyWindow?.rootViewController {
            root.present(av, animated: true)
        }
    }
}

struct GardenCanvas: View {
    let plants: [GardenPlant]

    var body: some View {
        Canvas { context, size in
            let ground = size.height * 0.88
            var groundPath = Path()
            groundPath.move(to: CGPoint(x: 0, y: ground))
            groundPath.addLine(to: CGPoint(x: size.width, y: ground))
            context.stroke(groundPath, with: .color(CurtailTheme.mint.opacity(0.4)), lineWidth: 1)

            for plant in plants {
                let x = plant.x * size.width
                let y = plant.y * size.height
                let h = (40 + plant.scale * 40)
                drawPlant(context: context, x: x, y: y, height: h, plant: plant)
            }
        }
    }

    private func drawPlant(context: GraphicsContext, x: Double, y: Double, height: Double, plant: GardenPlant) {
        var stem = Path()
        stem.move(to: CGPoint(x: x, y: y))
        stem.addLine(to: CGPoint(x: x, y: y - height))
        context.stroke(stem, with: .color(CurtailTheme.mint.opacity(0.8)), lineWidth: 2)

        if plant.isFlower {
            let flowerColor = Color(hue: plant.hue, saturation: 0.6, brightness: 0.85)
            let center = CGPoint(x: x, y: y - height)
            for i in 0..<5 {
                let angle = Double(i) * (2 * .pi / 5)
                let petalX = center.x + cos(angle) * 7
                let petalY = center.y + sin(angle) * 7
                context.fill(Path(ellipseIn: CGRect(x: petalX - 4, y: petalY - 4, width: 8, height: 8)), with: .color(flowerColor))
            }
            context.fill(Path(ellipseIn: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6)), with: .color(CurtailTheme.coral))
        } else {
            let leaf = Path(ellipseIn: CGRect(x: x - 8, y: y - height * 0.6, width: 14, height: 7))
            context.fill(leaf, with: .color(CurtailTheme.mint.opacity(0.7)))
        }
    }
}
