import SwiftUI
import WidgetKit

struct MediumQuoteView: View {
    let entry: QuoteEntry
    var showRefreshButton: Bool = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(spacing: 0) {
                // Quote area - tappable to quote page
                Link(destination: URL(string: "\(InspireMeAPI.baseURL)/quotes/\(entry.quote.id)")!) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\u{275D}")
                            .font(.title2)
                            .foregroundStyle(entry.theme.accentColor)

                        Text(entry.quote.content)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(entry.theme.textColor)
                            .lineLimit(4)
                            .minimumScaleFactor(0.8)

                        Spacer()
                    }
                    .padding(.leading, 14)
                    .padding(.vertical, 14)
                }

                Spacer()

                // Author area
                VStack(alignment: .trailing) {
                    Spacer()

                    Link(destination: URL(string: "\(InspireMeAPI.baseURL)/authors/\(entry.quote.authorSlug)")!) {
                        Text("— \(entry.quote.author)")
                            .font(.caption)
                            .foregroundStyle(entry.theme.secondaryTextColor)
                            .lineLimit(1)
                    }
                }
                .padding(.trailing, 14)
                .padding(.vertical, 14)
            }

            if showRefreshButton {
                Button(intent: RefreshQuoteIntent()) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                        .foregroundStyle(entry.theme.secondaryTextColor)
                }
                .buttonStyle(.plain)
                .padding(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(entry.theme.backgroundGradient)
    }
}

#Preview(as: .systemMedium) {
    RandomQuoteWidget()
} timeline: {
    QuoteEntry.placeholder
}
