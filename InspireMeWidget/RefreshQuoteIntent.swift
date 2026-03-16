import AppIntents
import WidgetKit

struct RefreshQuoteIntent: AppIntent {
    static let title: LocalizedStringResource = "새로고침"
    static let description: IntentDescription = "새로운 명언을 불러옵니다"

    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadTimelines(ofKind: "RandomQuoteWidget")
        return .result()
    }
}
