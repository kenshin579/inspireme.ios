import WidgetKit

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: Quote
    let theme: WidgetTheme

    static var placeholder: QuoteEntry {
        QuoteEntry(
            date: .now,
            quote: Quote(
                id: "placeholder",
                content: "천 리 길도 한 걸음부터 시작된다.",
                author: "노자",
                authorSlug: "lao-tzu",
                language: "ko",
                topics: ["motivation", "wisdom"],
                tags: nil
            ),
            theme: .gradient
        )
    }
}
