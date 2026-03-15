import SwiftUI
import WidgetKit

struct LockScreenQuoteView: View {
    let entry: QuoteEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.quote.content)
                    .font(.caption)
                    .lineLimit(2)
                Text("— \(entry.quote.author)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Text("❝")
                    .font(.title2)
            }

        case .accessoryInline:
            Text("\(entry.quote.content.prefix(30))… — \(entry.quote.author)")

        default:
            Text(entry.quote.content)
        }
    }
}
