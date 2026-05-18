import Foundation
import UserNotifications

enum NotificationAuthorizationState {
    case notDetermined
    case authorized
    case denied
}

@MainActor
struct NotificationScheduler {
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func pendingAuthorization() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    func authorizationState() async -> NotificationAuthorizationState {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }

    func scheduleEvents(referenceDate: Date, location: ObservingLocation) async {
        let events = CelestialCatalog.upcomingEvents(for: referenceDate, location: location, daysAhead: 2)

        center.removeAllPendingNotificationRequests()

        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        for event in events {
            let content = UNMutableNotificationContent()
            switch event.kind {
            case .enterHorizon:
                content.title = L10n.notificationTitleEnter(bodyName: event.bodyName)
            case .exitHorizon:
                content.title = L10n.notificationTitleExit(bodyName: event.bodyName)
            }
            content.body = L10n.notificationBody(
                locationName: location.name,
                dateText: formatter.string(from: event.date)
            )
            content.sound = .default

            let interval = max(event.date.timeIntervalSince(referenceDate), 1)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
            let request = UNNotificationRequest(identifier: event.id, content: content, trigger: trigger)

            try? await center.add(request)
        }
    }

    func clearPending() {
        center.removeAllPendingNotificationRequests()
    }

    func scheduleTestNotification(after seconds: TimeInterval = 5) async {
        let content = UNMutableNotificationContent()
        content.title = L10n.notificationTestTitle()
        content.body = L10n.notificationTestBody()
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(seconds, 1), repeats: false)
        let request = UNNotificationRequest(
            identifier: "test-notification-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }
}
