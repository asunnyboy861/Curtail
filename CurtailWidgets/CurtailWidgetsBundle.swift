import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct StartSurfProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry { SimpleEntry(date: .now) }
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        completion(SimpleEntry(date: .now))
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        completion(Timeline(entries: [SimpleEntry(date: .now)], policy: .never))
    }
}

struct StartSurfWidgetView: View {
    var entry: StartSurfProvider.Entry

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "water.waves")
                .font(.title2)
                .foregroundStyle(Color(hex: "5B8DEF"))
            Text("Start Surfing")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(Color(hex: "0B1220"))
        .widgetURL(URL(string: "curtail://sos"))
        .accessibilityLabel("Start urge surfing session")
    }
}

struct StartSurfWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "StartSurf", provider: StartSurfProvider()) { entry in
            StartSurfWidgetView(entry: entry)
        }
        .configurationDisplayName("SOS Surf")
        .description("Start urge surfing in one tap.")
        .supportedFamilies([.systemSmall, .accessoryRectangular, .accessoryCircular])
    }
}

import ActivityKit

@available(iOS 16.2, *)
struct SurfLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SurfActivityAttributes.self) { context in
            SurfLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    SurfLiveActivityView(context: context)
                }
            } compactLeading: {
                Image(systemName: "water.waves").foregroundStyle(Color(hex: "5B8DEF"))
            } compactTrailing: {
                Text(timerText(context.state.remainingSeconds)).monospacedDigit()
            } minimal: {
                Image(systemName: "water.waves").foregroundStyle(Color(hex: "5B8DEF"))
            }
        }
    }
}

@available(iOS 16.2, *)
struct SurfLiveActivityView: View {
    let context: ActivityViewContext<SurfActivityAttributes>

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "water.waves")
                .foregroundStyle(Color(hex: "5B8DEF"))
            VStack(alignment: .leading) {
                Text("Riding the wave")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("The urge passes. Stay on the board.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
            Text(timerText(context.state.remainingSeconds))
                .font(.title3.monospacedDigit().bold())
                .foregroundStyle(.white)
        }
        .padding()
        .activityBackgroundTint(Color(hex: "141C2E"))
    }
}

private func timerText(_ seconds: Int) -> String {
    String(format: "%d:%02d", seconds / 60, seconds % 60)
}

@main
struct CurtailWidgetsBundle: WidgetBundle {
    var body: some Widget {
        StartSurfWidget()
        if #available(iOS 16.2, *) {
            SurfLiveActivity()
        }
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

extension View {
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) { color }
        } else {
            background(color)
        }
    }
}
