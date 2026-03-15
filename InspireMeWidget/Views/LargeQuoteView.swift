import SwiftUI
import WidgetKit

struct LargeQuoteView: View {
    let entry: QuoteEntry
    var showRefreshButton: Bool = false
    var titleLabel: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: title + refresh button
            HStack {
                if let titleLabel {
                    Text(titleLabel)
                        .font(.caption.bold())
                        .foregroundStyle(entry.theme.secondaryTextColor)
                        .textCase(.uppercase)
                }

                Spacer()

                if showRefreshButton {
                    Button(intent: RefreshQuoteIntent()) {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                            .foregroundStyle(entry.theme.secondaryTextColor)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("\u{275D}")
                .font(.largeTitle)
                .foregroundStyle(entry.theme.accentColor)

            // Quote content - tappable
            Link(destination: URL(string: "\(InspireMeAPI.baseURL)/quotes/\(entry.quote.id)")!) {
                Text(entry.quote.content)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(entry.theme.textColor)
                    .lineLimit(6)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            // Author - tappable
            Link(destination: URL(string: "\(InspireMeAPI.baseURL)/authors/\(entry.quote.authorSlug)")!) {
                Text("— \(entry.quote.author)")
                    .font(.subheadline)
                    .foregroundStyle(entry.theme.secondaryTextColor)
            }

            // Topics
            if !entry.quote.topics.isEmpty {
                HStack(spacing: 6) {
                    ForEach(entry.quote.topics.prefix(4), id: \.self) { topic in
                        Text(topic)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(entry.theme.accentColor.opacity(0.2))
                            .foregroundStyle(entry.theme.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(entry.theme.backgroundGradient)
    }
}

#Preview(as: .systemLarge) {
    QuoteOfTheDayWidget()
} timeline: {
    QuoteEntry.placeholder
}
