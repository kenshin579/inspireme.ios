import SwiftUI

// MARK: - Small Quote Content

struct SmallQuoteContent: View {
    let quote: Quote
    let theme: WidgetTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\u{275D}")
                .font(.title2)
                .foregroundStyle(theme.accentColor)

            Text(quote.content)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.textColor)
                .lineLimit(4)
                .minimumScaleFactor(0.8)

            Spacer()

            Text("— \(quote.author)")
                .font(.caption)
                .foregroundStyle(theme.secondaryTextColor)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(theme.backgroundGradient)
    }
}

// MARK: - Medium Quote Content

struct MediumQuoteContent: View {
    let quote: Quote
    let theme: WidgetTheme
    var showRefreshButton: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("\u{275D}")
                    .font(.title2)
                    .foregroundStyle(theme.accentColor)

                Text(quote.content)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(theme.textColor)
                    .lineLimit(4)
                    .minimumScaleFactor(0.8)

                Spacer()
            }
            .padding(.leading, 14)
            .padding(.vertical, 14)

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Spacer()

                Text("— \(quote.author)")
                    .font(.caption)
                    .foregroundStyle(theme.secondaryTextColor)
                    .lineLimit(1)
            }
            .padding(.trailing, 14)
            .padding(.vertical, 14)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.backgroundGradient)
    }
}

// MARK: - Large Quote Content

struct LargeQuoteContent: View {
    let quote: Quote
    let theme: WidgetTheme
    var showRefreshButton: Bool = false
    var titleLabel: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let titleLabel {
                HStack {
                    Text(titleLabel)
                        .font(.caption.bold())
                        .foregroundStyle(theme.secondaryTextColor)
                        .textCase(.uppercase)
                    Spacer()
                }
            }

            Text("\u{275D}")
                .font(.largeTitle)
                .foregroundStyle(theme.accentColor)

            Text(quote.content)
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(theme.textColor)
                .lineLimit(6)
                .minimumScaleFactor(0.8)

            Spacer()

            Text("— \(quote.author)")
                .font(.subheadline)
                .foregroundStyle(theme.secondaryTextColor)

            if !quote.topics.isEmpty {
                HStack(spacing: 6) {
                    ForEach(quote.topics.prefix(4), id: \.self) { topic in
                        Text(topic)
                            .font(.caption2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(theme.accentColor.opacity(0.2))
                            .foregroundStyle(theme.accentColor)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(theme.backgroundGradient)
    }
}
