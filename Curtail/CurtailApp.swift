import SwiftUI
import SwiftData

@main
struct CurtailApp: App {
    @State private var router = AppRouter()

    let container: ModelContainer

    init() {
        let schema = Schema([SubstanceProfile.self, LifeEvent.self])
        if let cloudContainer = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(cloudKitDatabase: .automatic)
        ) {
            container = cloudContainer
        } else if let localContainer = try? ModelContainer(
            for: schema,
            configurations: ModelConfiguration(cloudKitDatabase: .none)
        ) {
            container = localContainer
        } else {
            container = try! ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .modelContainer(container)
                .preferredColorScheme(.dark)
                .tint(CurtailTheme.wave)
                .onOpenURL { url in
                    if url.scheme == "curtail", url.host == "sos" {
                        router.openSOS()
                    }
                }
        }
    }
}

@Observable
final class AppRouter {
    var showSOS = false

    func openSOS() {
        showSOS = true
    }
}
