import SwiftUI
import SwiftData

struct LogsTimelineView: View {
    @Query private var profiles: [SubstanceProfile]

    var body: some View {
        let allEvents: [(SubstanceProfile, LifeEvent)] = profiles.flatMap { profile in
            (profile.events ?? []).sorted { $0.timestamp > $1.timestamp }.map { (profile, $0) }
        }.sorted { $0.1.timestamp > $1.1.timestamp }

        return ScrollView {
            VStack(spacing: 12) {
                if allEvents.isEmpty {
                    Text("Your story shows up here — cravings ridden, check-ins, and data points.")
                        .foregroundStyle(CurtailTheme.textMid)
                        .multilineTextAlignment(.center)
                        .padding(.top, 60)
                }
                ForEach(Array(groupByDay(allEvents)), id: \.key) { day, events in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(day)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CurtailTheme.textMid)
                        ForEach(events, id: \.1.id) { profile, event in
                            NavigationLink {
                                EventEditView(event: event)
                            } label: {
                                EventRow(event: event, profileName: profile.name)
                            }
                        }
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(CurtailTheme.ink)
        .navigationTitle("Timeline")
    }

    private func groupByDay(_ events: [(SubstanceProfile, LifeEvent)]) -> [(key: String, value: [(SubstanceProfile, LifeEvent)])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        var groups: [String: [(SubstanceProfile, LifeEvent)]] = [:]
        for pair in events {
            let key = formatter.string(from: pair.1.timestamp)
            groups[key, default: []].append(pair)
        }
        return groups.sorted { $0.key > $1.key }
    }
}

struct EventRow: View {
    let event: LifeEvent
    let profileName: String

    private var icon: String {
        switch event.kind {
        case .cravingRidden: return "water.waves"
        case .slip: return "chart.point.filled"
        case .pledge: return "sun.max.fill"
        case .checkIn: return "heart.fill"
        }
    }

    private var label: String {
        switch event.kind {
        case .cravingRidden: return "Wave ridden"
        case .slip: return "Data point"
        case .pledge: return "Morning pledge"
        case .checkIn: return "Check-in"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(event.kind == .slip ? CurtailTheme.textMid : CurtailTheme.mint)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CurtailTheme.textHi)
                Text(profileName + (event.emotionTag.map { " · \($0)" } ?? ""))
                    .font(.caption)
                    .foregroundStyle(CurtailTheme.textMid)
            }
            Spacer()
            if event.editedAt != nil, StreakMath.isBackfillMarked(eventDate: event.timestamp) {
                Text("backfill")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(CurtailTheme.surface))
                    .foregroundStyle(CurtailTheme.textMid)
            }
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(CurtailTheme.textMid)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface))
        .accessibilityElement(children: .combine)
    }
}

struct EventEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var event: LifeEvent

    var body: some View {
        Form {
            Section("When") {
                DatePicker("Time", selection: $event.timestamp)
            }
            Section("Details") {
                TextField("Note", text: Binding(
                    get: { event.note ?? "" },
                    set: { event.note = $0.isEmpty ? nil : $0 }
                ))
                TextField("Emotion tag", text: Binding(
                    get: { event.emotionTag ?? "" },
                    set: { event.emotionTag = $0.isEmpty ? nil : $0 }
                ))
                TextField("Place tag", text: Binding(
                    get: { event.placeTag ?? "" },
                    set: { event.placeTag = $0.isEmpty ? nil : $0 }
                ))
            }
            Section {
                Button("Delete event", role: .destructive) {
                    context.delete(event)
                    try? context.save()
                    dismiss()
                }
            }
        }
        .onDisappear {
            event.editedAt = .now
            try? context.save()
        }
        .navigationTitle("Edit")
    }
}
