import SwiftUI

enum WidgetTheme: String, CaseIterable, Codable, Sendable {
    case gradient
    case dark
    case warm
    case nature
    case light

    var displayName: String {
        switch self {
        case .gradient: "보라색 그라데이션"
        case .dark: "다크 엘레건트"
        case .warm: "따뜻한 브라운"
        case .nature: "자연 그린"
        case .light: "라이트"
        }
    }

    var backgroundGradient: LinearGradient {
        switch self {
        case .gradient:
            LinearGradient(
                colors: [Color(red: 0.4, green: 0.2, blue: 0.8), Color(red: 0.6, green: 0.3, blue: 0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .dark:
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.2, green: 0.2, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .warm:
            LinearGradient(
                colors: [Color(red: 0.6, green: 0.35, blue: 0.2), Color(red: 0.75, green: 0.5, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .nature:
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.45, blue: 0.3), Color(red: 0.25, green: 0.6, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .light:
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.95, blue: 0.97), Color(red: 0.9, green: 0.9, blue: 0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    var textColor: Color {
        switch self {
        case .light: .primary
        default: .white
        }
    }

    var secondaryTextColor: Color {
        switch self {
        case .light: .secondary
        default: Color.white.opacity(0.8)
        }
    }

    var accentColor: Color {
        switch self {
        case .gradient: Color(red: 1.0, green: 0.8, blue: 0.4)
        case .dark: Color(red: 0.7, green: 0.7, blue: 0.9)
        case .warm: Color(red: 1.0, green: 0.85, blue: 0.6)
        case .nature: Color(red: 0.6, green: 0.9, blue: 0.7)
        case .light: Color(red: 0.4, green: 0.2, blue: 0.8)
        }
    }
}
