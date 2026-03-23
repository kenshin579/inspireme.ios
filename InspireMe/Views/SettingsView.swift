import SwiftUI
import WidgetKit

struct SettingsView: View {
    @State private var language = AppGroupManager.language
    @State private var refreshInterval = AppGroupManager.refreshInterval
    @State private var widgetTheme = AppGroupManager.widgetTheme
    @State private var colorSchemeMode = AppGroupManager.colorSchemeMode
    @State private var selectedTopics = AppGroupManager.selectedTopics
    @State private var newTopic = ""
    @State private var suggestedTopics: [String] = []
    @State private var searchTask: Task<Void, Never>?
    @State private var notificationEnabled = AppGroupManager.notificationEnabled
    @State private var notifyRandomQuote = AppGroupManager.notifyRandomQuote

    var body: some View {
        NavigationStack {
            Form {
                Section("언어") {
                    Picker("언어", selection: $language) {
                        Text("한국어").tag("ko")
                        Text("English").tag("en")
                    }
                }

                Section("갱신 주기") {
                    Stepper("\(refreshInterval)시간마다 갱신", value: $refreshInterval, in: 1...72)
                }

                Section("알림") {
                    Toggle("명언 변경 알림", isOn: $notificationEnabled)

                    if notificationEnabled {
                        Toggle("오늘의 명언", isOn: .constant(true))
                            .disabled(true)
                            .foregroundStyle(.secondary)

                        Toggle("랜덤 명언", isOn: $notifyRandomQuote)
                    }
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
                }

                Section("토픽 필터") {
                    HStack {
                        TextField("토픽 검색", text: $newTopic)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .onChange(of: newTopic) { _, newValue in
                                searchTopics(query: newValue)
                            }
                        if !newTopic.isEmpty {
                            Button {
                                newTopic = ""
                                suggestedTopics = []
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    if !suggestedTopics.isEmpty {
                        ForEach(suggestedTopics, id: \.self) { topic in
                            Button {
                                selectTopic(topic)
                            } label: {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                    Text(topic)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    if selectedTopics.contains(topic) {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(.purple)
                                            .font(.caption)
                                    } else {
                                        Image(systemName: "plus")
                                            .foregroundStyle(.purple)
                                            .font(.caption)
                                    }
                                }
                            }
                        }
                    }

                    if suggestedTopics.isEmpty && newTopic.isEmpty {
                        if selectedTopics.isEmpty {
                            Text("토픽을 검색하여 추가하면 해당 토픽의 명언만 표시됩니다.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if !selectedTopics.isEmpty {
                    Section("선택된 토픽") {
                        ForEach(selectedTopics, id: \.self) { topic in
                            HStack {
                                Text(topic)
                                Spacer()
                                Button {
                                    selectedTopics.removeAll { $0 == topic }
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
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
                AppGroupManager.selectedTopics = newValue
                reloadWidgets()
            }
            .onChange(of: notificationEnabled) { _, newValue in
                AppGroupManager.notificationEnabled = newValue
                if newValue {
                    Task {
                        let granted = await NotificationManager.shared.requestAuthorization()
                        if !granted {
                            notificationEnabled = false
                            AppGroupManager.notificationEnabled = false
                        }
                    }
                    BackgroundTaskManager.scheduleAppRefresh()
                }
            }
            .onChange(of: notifyRandomQuote) { _, newValue in
                AppGroupManager.notifyRandomQuote = newValue
            }
        }
    }

    private func searchTopics(query: String) {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            suggestedTopics = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            let api = InspireMeAPI()
            if let results = try? await api.searchTopics(query: trimmed, lang: language) {
                guard !Task.isCancelled else { return }
                suggestedTopics = results
            }
        }
    }

    private func selectTopic(_ topic: String) {
        if !selectedTopics.contains(topic) {
            selectedTopics.append(topic)
        }
        newTopic = ""
        suggestedTopics = []
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}

#Preview {
    SettingsView()
}
