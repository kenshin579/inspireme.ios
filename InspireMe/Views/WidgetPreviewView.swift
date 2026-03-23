import SwiftUI
import WidgetKit

struct WidgetPreviewView: View {
    private let theme = AppGroupManager.widgetTheme
    @State private var showToast = false

    private let sampleQuote = Quote(
        id: "sample",
        content: "천 리 길도 한 걸음부터 시작된다.",
        author: "노자",
        authorSlug: "lao-tzu",
        language: "ko",
        topics: ["motivation", "wisdom"],
        tags: nil
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("현재 위젯 미리보기")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    // Small widget preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Small")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        SmallQuoteContent(quote: sampleQuote, theme: theme)
                            .frame(width: 170, height: 170)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    // Medium widget preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Medium")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        MediumQuoteContent(quote: sampleQuote, theme: theme)
                            .frame(width: 360, height: 170)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    // Large widget preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Large")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        LargeQuoteContent(quote: sampleQuote, theme: theme)
                            .frame(width: 360, height: 376)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                }
                .padding()
            }
            .navigationTitle("위젯 미리보기")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        reloadWidgets()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .toast(message: "새로운 명언이 위젯에 표시되고 있습니다", isPresented: $showToast)
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
        withAnimation { showToast = true }
    }
}

#Preview {
    WidgetPreviewView()
}
