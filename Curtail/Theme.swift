import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        if hex.count == 6 {
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8) & 0xFF) / 255
            b = Double(int & 0xFF) / 255
        } else {
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b)
    }
}

enum CurtailTheme {
    static let ink = Color(hex: "0B1220")
    static let surface = Color(hex: "141C2E")
    static let wave = Color(hex: "5B8DEF")
    static let coral = Color(hex: "FF7E6B")
    static let mint = Color(hex: "59C9A5")
    static let textHi = Color.white.opacity(0.92)
    static let textMid = Color.white.opacity(0.55)

    static func timeAgo(_ seconds: TimeInterval) -> String {
        let days = Int(seconds / 86400)
        let hours = Int(seconds.truncatingRemainder(dividingBy: 86400) / 3600)
        let minutes = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
        if days > 0 { return "\(days)d \(hours)h" }
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(minutes)m"
    }
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(RoundedRectangle(cornerRadius: 20).fill(CurtailTheme.surface))
    }
}

extension View {
    func card() -> some View { modifier(CardBackground()) }
}
