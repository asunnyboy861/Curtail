import SwiftUI
import SwiftData

struct ProfilesView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [SubstanceProfile]
    @State private var showPaywall = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(profiles) { profile in
                    if !profile.isHidden {
                        ProfileCard(profile: profile)
                    }
                }
                addProfileCard
            }
            .padding(20)
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
        }
        .background(CurtailTheme.ink)
        .navigationTitle("Profiles")
        .sheet(isPresented: $showPaywall) { PaywallView() }
    }

    private var addProfileCard: some View {
        let freeLimit = 3
        let activeCount = profiles.filter { !$0.isHidden }.count
        return Button {
            if PurchaseManager.shared.isPro || activeCount < freeLimit {
                let profile = SubstanceProfile(name: "New focus", icon: "star.fill", mode: .abstinence)
                context.insert(profile)
            } else {
                showPaywall = true
            }
        } label: {
            Label("Add profile", systemImage: "plus.circle.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
        }
        .buttonStyle(.bordered)
        .tint(CurtailTheme.wave)
    }
}

struct ProfileCard: View {
    @Environment(\.modelContext) private var context
    @State private var showEditor = false
    let profile: SubstanceProfile

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: profile.icon)
                    .font(.title2)
                    .foregroundStyle(CurtailTheme.wave)
                Text(profile.name)
                    .font(.headline)
                    .foregroundStyle(CurtailTheme.textHi)
                Spacer()
                Text(profile.mode == .abstinence ? "Abstinence" : "Taper")
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(CurtailTheme.wave.opacity(0.2)))
                    .foregroundStyle(CurtailTheme.wave)
            }
            HStack(spacing: 12) {
                StatPill(label: "This lap", value: StreakMath.formatDuration(StreakMath.lapDuration(profile)), color: CurtailTheme.wave)
                StatPill(label: "Longest", value: StreakMath.formatDuration(profile.longestCleanSeconds), color: CurtailTheme.mint)
                StatPill(label: "Ridden", value: "\(profile.totalRiddenCravings)", color: CurtailTheme.coral)
            }
        }
        .card()
        .contextMenu {
            Button("Edit") { showEditor = true }
            Button(profile.isHidden ? "Unhide" : "Hide") {
                profile.isHidden.toggle()
                try? context.save()
            }
            Button("Delete", role: .destructive) {
                context.delete(profile)
                try? context.save()
            }
        }
        .sheet(isPresented: $showEditor) {
            ProfileEditorView(profile: profile)
        }
    }
}

struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var profile: SubstanceProfile

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("Name", text: $profile.name)
                }
                Section("Mode") {
                    Picker("Mode", selection: $profile.mode) {
                        Text("Full abstinence").tag(ProfileMode.abstinence)
                        Text("Gradual taper").tag(ProfileMode.taper)
                    }
                }
                Section("Chapter start") {
                    DatePicker("Start", selection: $profile.currentLapStart, displayedComponents: .date)
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        try? context.save()
                        dismiss()
                    }
                }
            }
        }
    }
}
