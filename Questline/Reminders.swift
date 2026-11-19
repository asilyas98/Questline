import Foundation
import UserNotifications

/// Schedules the next 30 daily reminders, each carrying that day's quote.
/// Re-scheduled every time the app becomes active, so the window keeps rolling forward.
enum Reminders {
    private static let ids = (0..<30).map { "questline-day-\($0)" }

    static func requestPermission(_ done: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { done(granted) }
        }
    }

    static func schedule(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ids)
        let cal = Calendar.current
        let now = Date()
        for i in 0..<30 {
            guard let day = cal.date(byAdding: .day, value: i, to: now) else { continue }
            var comps = cal.dateComponents([.year, .month, .day], from: day)
            comps.hour = hour
            comps.minute = minute
            guard let fire = cal.date(from: comps), fire > now else { continue }

            let q = Quotes.forDate(day)
            let content = UNMutableNotificationContent()
            content.title = "⚔️ Your quests await"
            content.body = "“\(q.text)” — \(q.author)"
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            center.add(UNNotificationRequest(identifier: ids[i], content: content, trigger: trigger))
        }
    }

    static func cancel() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
