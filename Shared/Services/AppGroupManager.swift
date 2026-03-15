import Foundation

struct AppGroupManager: Sendable {
    static let suiteName = "group.pe.kr.advenoh.inspireme"

    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    // MARK: - Keys

    private enum Keys {
        static let language = "language"
        static let refreshInterval = "refreshInterval"
        static let widgetTheme = "widgetTheme"
        static let selectedTopics = "selectedTopics"
        static let colorSchemeMode = "colorSchemeMode"
        static let cachedQuote = "cachedQuote"
    }

    // MARK: - Language

    static var language: String {
        get { defaults?.string(forKey: Keys.language) ?? "ko" }
        set { defaults?.set(newValue, forKey: Keys.language) }
    }

    // MARK: - Refresh Interval (hours)

    static var refreshInterval: Int {
        get {
            let value = defaults?.integer(forKey: Keys.refreshInterval) ?? 0
            return value > 0 ? value : 4
        }
        set { defaults?.set(newValue, forKey: Keys.refreshInterval) }
    }

    // MARK: - Widget Theme

    static var widgetTheme: WidgetTheme {
        get {
            guard let raw = defaults?.string(forKey: Keys.widgetTheme),
                  let theme = WidgetTheme(rawValue: raw) else {
                return .gradient
            }
            return theme
        }
        set { defaults?.set(newValue.rawValue, forKey: Keys.widgetTheme) }
    }

    // MARK: - Selected Topics

    static var selectedTopics: [String] {
        get { defaults?.stringArray(forKey: Keys.selectedTopics) ?? [] }
        set { defaults?.set(newValue, forKey: Keys.selectedTopics) }
    }

    // MARK: - Color Scheme Mode

    static var colorSchemeMode: String {
        get { defaults?.string(forKey: Keys.colorSchemeMode) ?? "system" }
        set { defaults?.set(newValue, forKey: Keys.colorSchemeMode) }
    }

    // MARK: - Cached Quote

    static var cachedQuote: Quote? {
        get {
            guard let data = defaults?.data(forKey: Keys.cachedQuote) else { return nil }
            return try? JSONDecoder().decode(Quote.self, from: data)
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            defaults?.set(data, forKey: Keys.cachedQuote)
        }
    }
}
