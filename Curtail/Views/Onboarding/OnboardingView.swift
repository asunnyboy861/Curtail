import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var context
    @State private var step = 0
    @State private var selectedAddiction: AddictionPreset?
    @State private var customName = ""
    @State private var mode: ProfileMode = .abstinence
    @State private var backdateDays = 0
    @State private var notificationsOn = false

    let presets: [AddictionPreset] = [
        .init(name: "Sugar", icon: "birthday.cake.fill"),
        .init(name: "Alcohol", icon: "wineglass.fill"),
        .init(name: "Cigarettes", icon: "flame.fill"),
        .init(name: "Vape", icon: "cloud.fill"),
        .init(name: "Shopping", icon: "bag.fill"),
        .init(name: "Short Video", icon: "play.rectangle.fill")
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $step) {
                presetStep.tag(0)
                modeStep.tag(1)
                startDateStep.tag(2)
                reminderStep.tag(3)
                seedStep.tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .background(CurtailTheme.ink)
    }

    private var presetStep: some View {
        VStack(spacing: 28) {
            Spacer()
            Text("What do you want to change?")
                .font(.system(.title, design: .rounded).bold())
                .foregroundStyle(CurtailTheme.textHi)
                .multilineTextAlignment(.center)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(presets, id: \.name) { preset in
                    addictionTile(preset)
                }
            }
            .padding(.horizontal, 24)
            HStack(spacing: 8) {
                Image(systemName: "pencil")
                    .foregroundStyle(CurtailTheme.textMid)
                TextField("Or type your own…", text: $customName)
                    .textFieldStyle(.plain)
                    .foregroundStyle(CurtailTheme.textHi)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(CurtailTheme.surface))
            .padding(.horizontal, 24)
            Button {
                selectedAddiction = AddictionPreset(name: customName, icon: "star.fill")
                customName = ""
                withAnimation { step = 1 }
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedAddiction == nil && customName.isEmpty)
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    private func addictionTile(_ preset: AddictionPreset) -> some View {
        let selected = selectedAddiction?.name == preset.name
        return Button {
            selectedAddiction = preset
        } label: {
            VStack(spacing: 10) {
                Image(systemName: preset.icon)
                    .font(.title)
                    .foregroundStyle(selected ? CurtailTheme.coral : CurtailTheme.wave)
                Text(preset.name)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(CurtailTheme.textHi)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(selected ? CurtailTheme.wave.opacity(0.25) : CurtailTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(selected ? CurtailTheme.wave : .clear, lineWidth: 2)
                    )
            )
        }
        .accessibilityLabel("Choose \(preset.name)")
    }

    private var modeStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Pick your pace")
                .font(.system(.title, design: .rounded).bold())
                .foregroundStyle(CurtailTheme.textHi)
            ForEach(ProfileMode.allCases, id: \.self) { m in
                Button {
                    mode = m
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(m == .abstinence ? "Full abstinence" : "Gradual taper")
                                .font(.headline)
                                .foregroundStyle(CurtailTheme.textHi)
                            Text(m == .abstinence ? "I want to stop completely." : "I want to cut back step by step.")
                                .font(.caption)
                                .foregroundStyle(CurtailTheme.textMid)
                        }
                        Spacer()
                        Image(systemName: mode == m ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(mode == m ? CurtailTheme.mint : CurtailTheme.textMid)
                    }
                    .padding(18)
                    .background(RoundedRectangle(cornerRadius: 16).fill(CurtailTheme.surface))
                }
                .padding(.horizontal, 24)
            }
            Button {
                withAnimation { step = 2 }
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    private var startDateStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("When did this chapter start?")
                .font(.system(.title, design: .rounded).bold())
                .foregroundStyle(CurtailTheme.textHi)
                .multilineTextAlignment(.center)
            Text("Your real history counts. Nothing resets.")
                .foregroundStyle(CurtailTheme.textMid)
            Button {
                backdateDays = 0
                withAnimation { step = 3 }
            } label: {
                Text("It starts today").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            Stepper(value: $backdateDays, in: 1...365) {
                HStack {
                    Text("I'm actually")
                    Text("\(backdateDays) days in").bold().foregroundStyle(CurtailTheme.mint)
                    Text("in")
                }
            }
            .padding(.horizontal, 24)
            .foregroundStyle(CurtailTheme.textHi)
            Button {
                withAnimation { step = 3 }
            } label: {
                Text("Continue").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .disabled(backdateDays == 0)
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    private var reminderStep: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Gentle reminders?")
                .font(.system(.title, design: .rounded).bold())
                .foregroundStyle(CurtailTheme.textHi)
            Text("Skip means no notifications, ever.")
                .foregroundStyle(CurtailTheme.textMid)
            Button {
                notificationsOn = false
                finish()
            } label: {
                Text("Skip").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal, 24)
            Button {
                notificationsOn = true
                finish()
            } label: {
                Text("Send me an evening check-in").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    private var seedStep: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "leaf.fill")
                .font(.system(size: 72))
                .foregroundStyle(CurtailTheme.mint)
            Text("Nothing resets.\nNothing lost.")
                .font(.system(.largeTitle, design: .rounded).bold())
                .foregroundStyle(CurtailTheme.textHi)
                .multilineTextAlignment(.center)
            Button {
                finish()
            } label: {
                Text("Enter Curtail").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            Spacer()
        }
    }

    private func finish() {
        let name = selectedAddiction?.name ?? "Custom"
        let icon = selectedAddiction?.icon ?? "star.fill"
        let lapStart = Date.now.addingTimeInterval(-Double(backdateDays) * 86400)
        let profile = SubstanceProfile(name: name, icon: icon, mode: mode, lapStart: lapStart)
        context.insert(profile)
        if notificationsOn {
            Task {
                if await NotificationScheduler.requestAuthorization() {
                    NotificationScheduler.scheduleEveningCheckIn()
                }
            }
        }
    }
}

struct AddictionPreset {
    let name: String
    let icon: String
}
