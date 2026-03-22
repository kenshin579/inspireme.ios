import SwiftUI
import BackgroundTasks
import UserNotifications

@main
struct InspireMeApp: App {
    @Environment(\.openURL) private var openURL
    @State private var widgetURL: URL?

    private let notificationDelegate = NotificationDelegate()

    init() {
        BackgroundTaskManager.registerTask()
        let delegate = notificationDelegate
        UNUserNotificationCenter.current().delegate = delegate
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if ProcessInfo.processInfo.isiOSAppOnMac {
                        openURL(url)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                        }
                    } else {
                        widgetURL = url
                    }
                }
                .fullScreenCover(item: $widgetURL) { url in
                    SafariView(url: url)
                        .ignoresSafeArea()
                }
                .task {
                    await NotificationManager.shared.requestAuthorization()
                    BackgroundTaskManager.scheduleAppRefresh()
                }
                .onReceive(NotificationCenter.default.publisher(for: .didReceiveQuoteNotification)) { notification in
                    if let url = notification.object as? URL {
                        widgetURL = url
                    }
                }
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}

extension Notification.Name {
    static let didReceiveQuoteNotification = Notification.Name("didReceiveQuoteNotification")
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        if let urlString = response.notification.request.content
            .userInfo["quoteURL"] as? String,
           let url = URL(string: urlString) {
            await MainActor.run {
                NotificationCenter.default.post(
                    name: .didReceiveQuoteNotification,
                    object: url
                )
            }
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
