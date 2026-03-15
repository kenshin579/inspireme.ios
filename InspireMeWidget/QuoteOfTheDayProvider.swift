import WidgetKit

struct QuoteOfTheDayProvider: TimelineProvider {
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

        Task {
            let api = InspireMeAPI()
            do {
                let quote = try await api.fetchQuoteOfTheDay(lang: lang)
                AppGroupManager.cachedQuote = quote

                let entry = QuoteEntry(date: .now, quote: quote, theme: theme)
                let nextMidnight = Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)
                let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
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
