import SwiftUI
import SantVaani
import SwiftData

@main
struct SantVaaniAppWrapper: App {
    // Shared container for SwiftData persistence
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            JournalEntry.self,
            SacredContent.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Register daily alerts on app launch
        NotificationManager.shared.requestAuthorization { granted, _ in
            if granted {
                NotificationManager.shared.scheduleJapReminders()
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            MainNavigationView()
        }
        .modelContainer(sharedModelContainer)
    }
}
