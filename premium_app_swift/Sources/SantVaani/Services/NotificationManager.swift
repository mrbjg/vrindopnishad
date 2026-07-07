import Foundation
import UserNotifications

public final class NotificationManager {
    public static let shared = NotificationManager()
    
    private init() {}
    
    public func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard let bundleID = Bundle.main.bundleIdentifier,
              !bundleID.contains("xctest"),
              !bundleID.hasPrefix("org.swift.pm") else {
            print("NotificationManager: Skipping requestAuthorization because process has no active app bundle.")
            completion(false, nil)
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            completion(granted, error)
        }
    }
    
    public func scheduleJapReminders(morningHour: Int = 7, eveningHour: Int = 20) {
        guard let bundleID = Bundle.main.bundleIdentifier,
              !bundleID.contains("xctest"),
              !bundleID.hasPrefix("org.swift.pm") else {
            print("NotificationManager: Skipping scheduleJapReminders because process has no active app bundle.")
            return
        }
        
        // Clear old reminders first to avoid duplicates
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let morningTitle = "प्रभात साधना काल"
        let morningBody = "हरे कृष्ण! सुबह की नाम जप साधना और दैनिक ज्ञान का समय हो गया है।"
        scheduleDailyNotification(hour: morningHour, minute: 0, identifier: "naam_jap_morning", title: morningTitle, body: morningBody)
        
        let eveningTitle = "संध्या नाम स्मरण"
        let eveningBody = "हरे कृष्ण! अपने आज के नाम जप के लक्ष्य को पूरा करें और शांति का अनुभव करें।"
        scheduleDailyNotification(hour: eveningHour, minute: 0, identifier: "naam_jap_evening", title: eveningTitle, body: eveningBody)
    }
    
    private func scheduleDailyNotification(hour: Int, minute: Int, identifier: String, title: String, body: String) {
        guard let bundleID = Bundle.main.bundleIdentifier,
              !bundleID.contains("xctest"),
              !bundleID.hasPrefix("org.swift.pm") else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification \(identifier): \(error)")
            }
        }
    }
}
