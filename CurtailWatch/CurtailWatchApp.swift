import SwiftUI
import WatchKit
import Combine
import UserNotifications

@main
struct CurtailWatchApp: App {
    var body: some Scene {
        WindowGroup {
            WatchSOSView()
        }
    }
}

struct WatchSOSView: View {
    @State private var isSurfing = false
    @State private var remaining: TimeInterval = 15
    @State private var riddenThisWeek = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 12) {
            if isSurfing {
                Text(String(format: "0:%02d", Int(remaining)))
                    .font(.system(size: 44, weight: .bold).monospacedDigit())
                    .foregroundStyle(Color(hex: "5B8DEF"))
                Text("Ride the wave")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            } else {
                Image(systemName: "water.waves")
                    .font(.title2)
                    .foregroundStyle(Color(hex: "5B8DEF"))
                Button {
                    startSurf()
                } label: {
                    Text("SOS")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: "5B8DEF"))
                Text("Ridden: \(riddenThisWeek)")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding()
        .background(Color(hex: "0B1220"))
        .onReceive(timer) { _ in
            guard isSurfing else { return }
            remaining -= 1
            WKInterfaceDevice.current().play(.click)
            if remaining <= 0 { completeSurf() }
        }
        .onAppear { riddenThisWeek = WristRideStore.ridesThisWeek() }
    }

    private func startSurf() {
        isSurfing = true
        remaining = 15
        WKInterfaceDevice.current().play(.start)
    }

    private func completeSurf() {
        isSurfing = false
        remaining = 15
        WKInterfaceDevice.current().play(.success)
        WristRideStore.recordRide()
        riddenThisWeek = WristRideStore.ridesThisWeek()
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

enum WristRideStore {
    static func ridesThisWeek() -> Int {
        guard let defaults = UserDefaults(suiteName: "group.com.zzoutuo.Curtail") else { return 0 }
        let weekAgo = Date.now.addingTimeInterval(-7 * 86400).timeIntervalSince1970
        let rides = defaults.array(forKey: "wristRides") as? [Double] ?? []
        return rides.filter { $0 >= weekAgo }.count
    }

    static func recordRide() {
        guard let defaults = UserDefaults(suiteName: "group.com.zzoutuo.Curtail") else { return }
        var rides = defaults.array(forKey: "wristRides") as? [Double] ?? []
        rides.append(Date.now.timeIntervalSince1970)
        rides = rides.filter { $0 >= Date.now.addingTimeInterval(-30 * 86400).timeIntervalSince1970 }
        defaults.set(rides, forKey: "wristRides")
    }
}
