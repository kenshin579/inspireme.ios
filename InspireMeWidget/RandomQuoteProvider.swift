import WidgetKit

struct RandomQuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        if let cached = AppGroupManager.cachedQuote {
            completion(QuoteEntry(date: .now, quote: cached, theme: AppGroupManager.widgetTheme))
        } else {
            completion(.placeholder)
        }
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<QuoteEntry>) -> Void) {
        let lang = AppGroupManager.language
        let theme = AppGroupManager.widgetTheme
        let topics = AppGroupManager.selectedTopics
        let intervalHours = AppGroupManager.refreshInterval

        Task {
            let api = InspireMeAPI()
            do {
                let topicsParam = topics.isEmpty ? nil : topics
                let quote = try await api.fetchRandomQuote(lang: lang, topics: topicsParam)
                AppGroupManager.cachedQuote = quote

                let entry = QuoteEntry(date: .now, quote: quote, theme: theme)
                let nextRefresh = Date.now.addingTimeInterval(Double(intervalHours) * 3600)
                let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
                completion(timeline)
            } catch {
                let fallback = AppGroupManager.cachedQuote ?? QuoteEntry.placeholder.quote
                let entry = QuoteEntry(date: .now, quote: fallback, theme: theme)
                let retryDate = Date.now.addingTimeInterval(1800)
                let timeline = Timeline(entries: [entry], policy: .after(retryDate))
                completion(timeline)
            }
        }
    }
}
