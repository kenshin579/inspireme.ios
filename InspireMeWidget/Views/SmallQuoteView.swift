import SwiftUI
import WidgetKit

struct SmallQuoteView: View {
    let entry: QuoteEntry

    var body: some View {
        Link(destination: URL(string: "\(InspireMeAPI.baseURL)/quotes/\(entry.quote.id)")!) {
            SmallQuoteContent(quote: entry.quote, theme: entry.theme)
        }
    }
}

#Preview(as: .systemSmall) {
    QuoteOfTheDayWidget()
} timeline: {
    QuoteEntry.placeholder
}
