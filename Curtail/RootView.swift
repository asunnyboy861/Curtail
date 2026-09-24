import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var context
    @Query private var profiles: [SubstanceProfile]

    var body: some View {
        if profiles.isEmpty {
            NavigationStack {
                OnboardingView()
            }
        } else {
            mainTabs
        }
    }

    private var mainTabs: some View {
        TabView {
            NavigationStack {
                HomeView()
            }
            .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack {
                LogsTimelineView()
            }
            .tabItem { Label("Timeline", systemImage: "list.bullet") }

            NavigationStack {
                RadarView()
            }
            .tabItem { Label("Radar", systemImage: "scope") }

            NavigationStack {
                GardenView()
            }
            .tabItem { Label("Garden", systemImage: "leaf.fill") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .tint(CurtailTheme.wave)
        .fullScreenCover(isPresented: Binding(
            get: { router.showSOS },
            set: { router.showSOS = $0 }
        )) {
            SOSView()
        }
    }
}
