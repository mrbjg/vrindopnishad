import SwiftUI
import SwiftData

public struct SantVaaniApp: App {
    @State private var onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")
    @State private var isAuthenticated = UserDefaults.standard.bool(forKey: "is_authenticated")
    
    // Shared container for SwiftData persistence
    private var sharedModelContainer: ModelContainer = {
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

    public init() {
        // Register daily morning and evening alerts on app launch
        NotificationManager.shared.requestAuthorization { granted, _ in
            if granted {
                NotificationManager.shared.scheduleJapReminders()
            }
        }
    }

    public var body: some Scene {
        WindowGroup {
            ZStack {
                if !onboardingCompleted {
                    OnboardingView {
                        UserDefaults.standard.set(true, forKey: "onboarding_completed")
                        withAnimation {
                            onboardingCompleted = true
                        }
                    }
                } else if !isAuthenticated {
                    AuthView {
                        UserDefaults.standard.set(true, forKey: "is_authenticated")
                        withAnimation {
                            isAuthenticated = true
                        }
                    }
                } else {
                    MainNavigationView()
                }
            }
            .preferredColorScheme(ThemeManager.shared.isDark ? .dark : .light)
        }
        .modelContainer(sharedModelContainer)
    }
}
