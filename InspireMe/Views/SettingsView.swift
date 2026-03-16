import SwiftUI
import WidgetKit

struct SettingsView: View {
    @State private var language = AppGroupManager.language
    @State private var refreshInterval = AppGroupManager.refreshInterval
    @State private var widgetTheme = AppGroupManager.widgetTheme
    @State private var colorSchemeMode = AppGroupManager.colorSchemeMode
    @State private var selectedTopics = Set(AppGroupManager.selectedTopics)

    private let availableTopics = [
        "motivation", "happiness", "love", "success",
        "wisdom", "life", "friendship", "courage"
    ]

    private let topicDisplayNames: [String: String] = [
        "motivation": "동기부여",
        "happiness": "행복",
        "love": "사랑",
        "success": "성공",
        "wisdom": "지혜",
        "life": "삶",
        "friendship": "우정",
        "courage": "용기"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("언어") {
                    Picker("언어", selection: $language) {
                        Text("한국어").tag("ko")
                        Text("English").tag("en")
                    }
                    .pickerStyle(.segmented)
                }

                Section("갱신 주기") {
                    Picker("갱신 주기", selection: $refreshInterval) {
                        Text("1시간").tag(1)
                        Text("4시간").tag(4)
                        Text("하루").tag(24)
                    }
                    .pickerStyle(.segmented)
                }

                Section("테마") {
                    ForEach(WidgetTheme.allCases, id: \.self) { theme in
                        HStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(theme.backgroundGradient)
                                .frame(width: 40, height: 40)

                            Text(theme.displayName)

                            Spacer()

                            if theme == widgetTheme {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.purple)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            widgetTheme = theme
                        }
                    }
                }

                Section("다크 모드") {
                    Picker("다크 모드", selection: $colorSchemeMode) {
                        Text("시스템").tag("system")
                        Text("다크").tag("dark")
                        Text("라이트").tag("light")
                    }
                    .pickerStyle(.segmented)
                }

                Section("토픽 필터") {
                    ForEach(availableTopics, id: \.self) { topic in
                        Toggle(
                            topicDisplayNames[topic] ?? topic,
                            isOn: Binding(
                                get: { selectedTopics.contains(topic) },
                                set: { isOn in
                                    if isOn {
                                        selectedTopics.insert(topic)
                                    } else {
                                        selectedTopics.remove(topic)
                                    }
                                }
                            )
                        )
                    }
                }
            }
            .navigationTitle("설정")
            .onChange(of: language) { _, newValue in
                AppGroupManager.language = newValue
                reloadWidgets()
            }
            .onChange(of: refreshInterval) { _, newValue in
                AppGroupManager.refreshInterval = newValue
                reloadWidgets()
            }
            .onChange(of: widgetTheme) { _, newValue in
                AppGroupManager.widgetTheme = newValue
                reloadWidgets()
            }
            .onChange(of: colorSchemeMode) { _, newValue in
                AppGroupManager.colorSchemeMode = newValue
                reloadWidgets()
            }
            .onChange(of: selectedTopics) { _, newValue in
                AppGroupManager.selectedTopics = Array(newValue)
                reloadWidgets()
            }
        }
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    SettingsView()
}
