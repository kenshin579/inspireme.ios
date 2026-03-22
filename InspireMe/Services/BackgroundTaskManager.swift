import BackgroundTasks

struct BackgroundTaskManager: Sendable {
    static let taskIdentifier = "pe.kr.advenoh.inspireme.quote-refresh"

    static func registerTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleAppRefresh(task: refreshTask)
        }
    }

    static func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()

        let fetchTask = Task {
            guard AppGroupManager.notificationEnabled else {
                task.setTaskCompleted(success: true)
                return
            }

            let api = InspireMeAPI()
            let lang = AppGroupManager.language

            do {
                let newQuote = try await api.fetchQuoteOfTheDay(lang: lang)
                let previousQuote = AppGroupManager.cachedQuote

                if previousQuote?.id != newQuote.id {
                    await NotificationManager.shared
                        .scheduleQuoteNotification(quote: newQuote)
                    AppGroupManager.cachedQuote = newQuote
                }

                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            fetchTask.cancel()
        }
    }
}
