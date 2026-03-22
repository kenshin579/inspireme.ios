import UserNotifications

actor NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    func scheduleQuoteNotification(quote: Quote) async {
        guard AppGroupManager.notificationEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = quote.language == "en"
            ? "Today's quote has arrived"
            : "오늘의 명언이 도착했습니다"
        content.body = "\"\(quote.content)\" — \(quote.author)"
        content.sound = .default
        content.userInfo = [
            "quoteURL": "https://inspireme.advenoh.pe.kr/quotes/\(quote.id)"
        ]

        let request = UNNotificationRequest(
            identifier: "quote-of-the-day",
            content: content,
            trigger: nil
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    func removeAllPending() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
}
