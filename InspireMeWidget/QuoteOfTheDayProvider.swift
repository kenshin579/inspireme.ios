import WidgetKit

struct QuoteOfTheDayProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        if let cached = AppGroupManager.cachedQuote {
            completion(QuoteEntry(date: .now, quote: cached, theme: AppGroupManager.widgetTheme, colorSchemeMode: AppGroupManager.colorSchemeMode))
        } else {
            completion(.placeholder)
        }
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<QuoteEntry>) -> Void) {
        let lang = AppGroupManager.language
        let theme = AppGroupManager.widgetTheme
        let colorSchemeMode = AppGroupManager.colorSchemeMode

        Task {
            let api = InspireMeAPI()
            do {
                let quote = try await api.fetchQuoteOfTheDay(lang: lang)
                AppGroupManager.cachedQuote = quote

                let entry = QuoteEntry(date: .now, quote: quote, theme: theme, colorSchemeMode: colorSchemeMode)
                let nextMidnight = Calendar.current.startOfDay(for: .now).addingTimeInterval(86400)
                let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
                completion(timeline)
            } catch {
                let fallback = AppGroupManager.cachedQuote ?? QuoteEntry.placeholder.quote
                let entry = QuoteEntry(date: .now, quote: fallback, theme: theme, colorSchemeMode: colorSchemeMode)
                let retryDate = Date.now.addingTimeInterval(1800)
                let timeline = Timeline(entries: [entry], policy: .after(retryDate))
                completion(timeline)
            }
        }
    }
}
