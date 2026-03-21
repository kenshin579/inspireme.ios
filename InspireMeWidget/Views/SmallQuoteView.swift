import SwiftUI
import WidgetKit

struct SmallQuoteView: View {
    let entry: QuoteEntry

    var body: some View {
        Link(destination: entry.quoteURL) {
            SmallQuoteContent(quote: entry.quote, theme: entry.theme)
        }
    }
}

#Preview(as: .systemSmall) {
    QuoteOfTheDayWidget()
} timeline: {
    QuoteEntry.placeholder
}
