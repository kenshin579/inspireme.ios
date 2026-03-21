import SwiftUI
import WidgetKit

struct RandomQuoteWidget: Widget {
    let kind: String = "RandomQuoteWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RandomQuoteProvider()) { entry in
            RandomQuoteWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    entry.theme.backgroundGradient
                }
        }
        .contentMarginsDisabled()
        .configurationDisplayName("랜덤 명언")
        .description("설정한 주기마다 새로운 명언을 보여줍니다")
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

struct RandomQuoteWidgetEntryView: View {
    let entry: QuoteEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallQuoteView(entry: entry)
            case .systemMedium:
                MediumQuoteView(entry: entry, showRefreshButton: true)
            case .systemLarge:
                LargeQuoteView(entry: entry, showRefreshButton: true, titleLabel: "랜덤 명언")
            case .accessoryRectangular, .accessoryCircular, .accessoryInline:
                LockScreenQuoteView(entry: entry)
            default:
                SmallQuoteView(entry: entry)
            }
        }
        .preferredColorScheme(entry.preferredColorScheme)
    }
}
