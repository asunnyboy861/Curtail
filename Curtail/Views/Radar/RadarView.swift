import SwiftUI
import SwiftData

struct RadarView: View {
    @Query private var profiles: [SubstanceProfile]

    var body: some View {
        let allEvents = profiles.flatMap { $0.events ?? [] }
        let buckets = TriggerRadar.buckets(events: allEvents)
        let maxCount = max(1, buckets.map { $0.count }.max() ?? 1)
        let emotions = TriggerRadar.topEmotions(events: allEvents)

        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Trigger Radar")
                    .font(.system(.title2, design: .rounded).bold())
                    .foregroundStyle(CurtailTheme.textHi)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        ForEach(RadarBucket.slots, id: \.self) { slot in
                            Text(slot.prefix(3))
                                .font(.caption2)
                                .foregroundStyle(CurtailTheme.textMid)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    ForEach(0..<7) { weekday in
                        HStack(spacing: 4) {
                            Text(RadarBucket.weekdays[weekday])
                                .font(.caption2)
                                .foregroundStyle(CurtailTheme.textMid)
                                .frame(width: 36, alignment: .leading)
                            ForEach(0..<4) { slot in
                                let idx = weekday * 4 + slot
                                let count = buckets[idx].count
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(heatColor(count: count, max: maxCount))
                                    .frame(height: 36)
                                    .overlay(
                                        count > 0 ? Text("\(count)")
                                            .font(.caption2)
                                            .foregroundStyle(CurtailTheme.textHi)
                                            : nil
                                    )
                            }
                        }
                    }
                }
                .card()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Top emotions")
                        .font(.caption)
                        .foregroundStyle(CurtailTheme.textMid)
                    ForEach(emotions) { emo in
                        HStack {
                            Text(emo.emotion.capitalized)
                                .foregroundStyle(CurtailTheme.textHi)
                            Spacer()
                            Text("\(emo.count)").foregroundStyle(CurtailTheme.coral)
                        }
                        .font(.subheadline)
                    }
                    if emotions.isEmpty {
                        Text("Nothing logged yet — your radar builds as you ride waves or log data points.")
                            .font(.caption)
                            .foregroundStyle(CurtailTheme.textMid)
                    }
                }
                .card()
            }
            .padding(20)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(CurtailTheme.ink)
        .navigationTitle("Radar")
    }

    private func heatColor(count: Int, max: Int) -> Color {
        guard count > 0 else { return CurtailTheme.surface }
        let intensity = Double(count) / Double(max)
        return CurtailTheme.coral.opacity(0.2 + intensity * 0.7)
    }
}
