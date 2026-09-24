import Foundation
import UserNotifications

enum NotificationScheduler {
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
    }

    static func scheduleEveningCheckIn(hour: Int = 20) {
        let content = UNMutableNotificationContent()
        content.title = "Evening check-in"
        content.body = "Evening check-in takes 10 seconds. No pressure."
        content.sound = .default
        var components = DateComponents()
        components.hour = hour
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "evening_checkin", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func scheduleTrialReminder(daysFromNow: Double) {
        let fireDate = Date.now.addingTimeInterval(daysFromNow * 86400 - 48 * 3600)
        guard fireDate > .now else { return }
        let content = UNMutableNotificationContent()
        content.title = "Trial ends tomorrow"
        content.body = "Cancel anytime in Settings — nothing was lost."
        content.sound = .default
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "trial_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
