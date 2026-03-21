import SwiftUI
import WidgetKit

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: Quote
    let theme: WidgetTheme
    let colorSchemeMode: String // "system" | "dark" | "light"

    var preferredColorScheme: ColorScheme? {
        switch colorSchemeMode {
        case "dark": .dark
        case "light": .light
        default: nil // system
        }
    }

    var quoteURL: URL {
        if quote.id == "placeholder" {
            URL(string: InspireMeAPI.baseURL)!
        } else {
            URL(string: "\(InspireMeAPI.baseURL)/quotes/\(quote.id)")!
        }
    }

    var authorURL: URL {
        if quote.authorSlug.isEmpty || quote.id == "placeholder" {
            URL(string: InspireMeAPI.baseURL)!
        } else {
            URL(string: "\(InspireMeAPI.baseURL)/authors/\(quote.authorSlug)")!
        }
    }

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
            theme: .gradient,
            colorSchemeMode: "system"
        )
    }
}
