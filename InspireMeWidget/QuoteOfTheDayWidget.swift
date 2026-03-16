import SwiftUI
import WidgetKit

struct QuoteOfTheDayWidget: Widget {
    let kind: String = "QuoteOfTheDayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteOfTheDayProvider()) { entry in
            QuoteOfTheDayWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    entry.theme.backgroundGradient
                }
        }
        .configurationDisplayName("오늘의 명언")
        .description("매일 새로운 명언을 만나보세요")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline
        ])
    }
}

struct QuoteOfTheDayWidgetEntryView: View {
    let entry: QuoteEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallQuoteView(entry: entry)
            case .systemMedium:
                MediumQuoteView(entry: entry)
            case .systemLarge:
                LargeQuoteView(entry: entry, titleLabel: "오늘의 명언")
            case .accessoryRectangular, .accessoryCircular, .accessoryInline:
                LockScreenQuoteView(entry: entry)
            default:
                SmallQuoteView(entry: entry)
            }
        }
        .preferredColorScheme(entry.preferredColorScheme)
    }
}
