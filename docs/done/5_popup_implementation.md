# 명언 변경 알림 — 구현 문서

## 1. 프로젝트 설정 변경

### 1.1 project.yml — Background Modes 추가

InspireMe 메인 앱 타겟에 Background Modes capability 추가:

```yaml
# project.yml > targets > InspireMe > settings
targets:
  InspireMe:
    capabilities:
      Application Groups:
        groups:
          - group.pe.kr.advenoh.inspireme
      Background Modes:
        modes:
          - fetch       # BGAppRefreshTask용
```

### 1.2 project.yml — Info.plist 설정 추가

```yaml
# project.yml > targets > InspireMe > info > properties
targets:
  InspireMe:
    info:
      properties:
        BGTaskSchedulerPermittedIdentifiers:
          - pe.kr.advenoh.inspireme.quote-refresh
```

### 1.3 xcodegen generate 실행 필수

설정 변경 후 `xcodegen generate`로 프로젝트 재생성.

## 2. 새로운 파일

### 2.1 NotificationManager.swift (`Shared/Services/`)

알림 권한 관리 및 Local Notification 스케줄링을 담당하는 actor.

```swift
import UserNotifications

actor NotificationManager {
    static let shared = NotificationManager()

    // 알림 권한 요청
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // 알림 권한 상태 확인
    func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    // 명언 변경 알림 스케줄링
    func scheduleQuoteNotification(quote: Quote) async {
        guard AppGroupManager.notificationEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = quote.language == "en"
            ? "Today's quote has arrived"
            : "오늘의 명언이 도착했습니다"
        content.body = "\"\(quote.content)\" — \(quote.author)"
        content.sound = .default

        // Deep Link: 알림 탭 시 해당 명언 페이지 열기
        content.userInfo = [
            "quoteURL": "https://inspireme.advenoh.pe.kr/quotes/\(quote.id)"
        ]

        let request = UNNotificationRequest(
            identifier: "quote-of-the-day",
            content: content,
            trigger: nil  // 즉시 발송
        )

        try? await UNUserNotificationCenter.current().add(request)
    }

    // 대기 중인 알림 제거
    func removeAllPending() {
        UNUserNotificationCenter.current()
            .removeAllPendingNotificationRequests()
    }
}
```

**핵심 포인트**:
- `actor`로 선언하여 Swift 6 Strict Concurrency 준수
- `Shared/Services/`에 배치 — 향후 macOS에서도 사용 가능
- `userInfo`에 quoteURL 포함하여 알림 탭 시 Deep Link 처리
- `identifier: "quote-of-the-day"`로 동일 알림 중복 방지

### 2.2 BackgroundTaskManager.swift (`InspireMe/Services/`)

BGAppRefreshTask 등록 및 실행 처리.

```swift
import BackgroundTasks

struct BackgroundTaskManager {
    static let taskIdentifier = "pe.kr.advenoh.inspireme.quote-refresh"

    // BGTask 등록 — AppDelegate/App init에서 호출
    static func registerTask() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: taskIdentifier,
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleAppRefresh(task: refreshTask)
        }
    }

    // 다음 백그라운드 실행 스케줄링
    static func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        // 최소 1시간 후 실행 (시스템이 최적 시점 결정)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
        try? BGTaskScheduler.shared.submit(request)
    }

    // 백그라운드 실행 핸들러
    private static func handleAppRefresh(task: BGAppRefreshTask) {
        // 다음 실행 예약
        scheduleAppRefresh()

        let fetchTask = Task {
            guard AppGroupManager.notificationEnabled else {
                task.setTaskCompleted(success: true)
                return
            }

            let api = InspireMeAPI()
            let lang = AppGroupManager.language

            do {
                let newQuote = try await api.fetchQuoteOfTheDay(lang: lang)
                let previousQuote = AppGroupManager.cachedQuote

                // 명언이 변경되었으면 알림 발송
                if previousQuote?.id != newQuote.id {
                    await NotificationManager.shared
                        .scheduleQuoteNotification(quote: newQuote)
                    AppGroupManager.cachedQuote = newQuote
                }

                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }

        // 만료 시 Task 취소
        task.expirationHandler = {
            fetchTask.cancel()
        }
    }
}
```

**핵심 포인트**:
- `BGAppRefreshTask` 사용 — 시스템이 최적 시점에 앱을 깨움
- `previousQuote?.id != newQuote.id`로 변경 여부 판단
- `handleAppRefresh` 완료 시 다음 실행을 다시 예약
- `expirationHandler`에서 Task 취소하여 시간 초과 대응
- macOS 13+에서도 `BGTaskScheduler` 사용 가능

### 2.3 ToastView.swift (`InspireMe/Views/`)

In-App 토스트 UI 컴포넌트.

```swift
import SwiftUI

struct ToastView: View {
    let message: String
    @Binding var isPresented: Bool

    var body: some View {
        if isPresented {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.white)
                Text(message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.green.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { isPresented = false }
                }
            }
        }
    }
}
```

**핵심 포인트**:
- 3초 후 자동 사라짐
- `.transition(.move(edge: .top))`으로 상단에서 슬라이드
- `@Binding var isPresented`로 부모에서 제어

### 2.4 ToastModifier — View Extension으로 사용 편의성 제공

```swift
// ToastView.swift 하단에 추가
struct ToastModifier: ViewModifier {
    let message: String
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            ToastView(message: message, isPresented: $isPresented)
        }
        .animation(.spring(duration: 0.3), value: isPresented)
    }
}

extension View {
    func toast(message: String, isPresented: Binding<Bool>) -> some View {
        modifier(ToastModifier(message: message, isPresented: isPresented))
    }
}
```

사용법:
```swift
SomeView()
    .toast(message: "새로운 명언이 위젯에 표시되고 있습니다", isPresented: $showToast)
```

## 3. 기존 파일 수정

### 3.1 AppGroupManager.swift — 알림 설정 속성 추가

`Keys` enum에 추가:
```swift
case notificationEnabled = "notificationEnabled"
case notifyRandomQuote = "notifyRandomQuote"
```

computed property 추가:
```swift
static var notificationEnabled: Bool {
    get { defaults?.bool(forKey: Keys.notificationEnabled.rawValue) ?? true }
    set { defaults?.set(newValue, forKey: Keys.notificationEnabled.rawValue) }
}

static var notifyRandomQuote: Bool {
    get { defaults?.bool(forKey: Keys.notifyRandomQuote.rawValue) ?? false }
    set { defaults?.set(newValue, forKey: Keys.notifyRandomQuote.rawValue) }
}
```

### 3.2 InspireMeApp.swift — BGTask 등록 + 알림 딥링크

```swift
import SwiftUI
import BackgroundTasks  // 추가

@main
struct InspireMeApp: App {
    @Environment(\.openURL) private var openURL
    @State private var widgetURL: URL?

    init() {
        // BGTask 등록 (앱 시작 시 반드시 호출)
        BackgroundTaskManager.registerTask()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if ProcessInfo.processInfo.isiOSAppOnMac {
                        openURL(url)
                        NSApplication.shared.terminate(nil)
                    } else {
                        widgetURL = url
                    }
                }
                .fullScreenCover(item: $widgetURL) { url in
                    SafariView(url: url)
                }
                .task {
                    // 알림 권한 요청 (온보딩 완료 후)
                    await NotificationManager.shared.requestAuthorization()
                    // 백그라운드 갱신 스케줄링
                    BackgroundTaskManager.scheduleAppRefresh()
                }
        }
    }
}
```

**알림 탭 → Deep Link 처리**:

`UNUserNotificationCenterDelegate`를 통해 알림 탭 시 quoteURL을 추출하여 `widgetURL`에 연결. 기존 `onOpenURL` + `SafariView` 흐름을 그대로 활용.

```swift
// InspireMeApp.swift 또는 별도 AppDelegate에서
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    var onQuoteURL: ((URL) -> Void)?

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        if let urlString = response.notification.request.content
            .userInfo["quoteURL"] as? String,
           let url = URL(string: urlString) {
            onQuoteURL?(url)
        }
    }

    // Foreground에서도 알림 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
```

### 3.3 SettingsView.swift — 알림 설정 섹션 추가

기존 "갱신 주기" 섹션 아래에 "알림" 섹션 추가:

```swift
// State 추가
@State private var notificationEnabled = AppGroupManager.notificationEnabled
@State private var notifyRandomQuote = AppGroupManager.notifyRandomQuote

// Form 내부에 Section 추가
Section("알림") {
    Toggle("명언 변경 알림", isOn: $notificationEnabled)

    if notificationEnabled {
        Toggle("오늘의 명언", isOn: .constant(true))
            .disabled(true)
            .foregroundStyle(.secondary)

        Toggle("랜덤 명언", isOn: $notifyRandomQuote)
    }
}

// onChange 핸들러 추가
.onChange(of: notificationEnabled) { _, newValue in
    AppGroupManager.notificationEnabled = newValue
    if newValue {
        Task { await NotificationManager.shared.requestAuthorization() }
        BackgroundTaskManager.scheduleAppRefresh()
    }
}
.onChange(of: notifyRandomQuote) { _, newValue in
    AppGroupManager.notifyRandomQuote = newValue
}
```

### 3.4 WidgetPreviewView.swift — Toast 연동

위젯 새로고침 시 토스트 표시:

```swift
@State private var showToast = false

var body: some View {
    // 기존 뷰
    NavigationStack {
        // ... 기존 내용
    }
    .toast(message: "새로운 명언이 위젯에 표시되고 있습니다", isPresented: $showToast)
}

// reloadWidgets() 호출 시 토스트 표시
private func reloadWidgets() {
    WidgetCenter.shared.reloadAllTimelines()
    withAnimation { showToast = true }
}
```

## 4. macOS 지원

### 4.1 BGTaskScheduler macOS 차이점

- macOS 13+에서 `BGTaskScheduler` 사용 가능
- `BGAppRefreshTask`는 macOS에서도 동일하게 동작
- `UNUserNotificationCenter`는 macOS에서 기본 지원

### 4.2 플랫폼 분기 처리

현재 프로젝트가 Mac Catalyst로 동작하므로, 대부분의 코드가 양 플랫폼에서 동작한다. 플랫폼별 분기가 필요한 부분:

```swift
// InspireMeApp.swift에서 이미 사용 중인 패턴
if ProcessInfo.processInfo.isiOSAppOnMac {
    // macOS 전용 처리
}
```

`BGTaskScheduler`와 `UNUserNotificationCenter`는 별도 분기 없이 iOS/macOS 모두 동작.

## 5. 파일 변경 요약

| 파일 | 작업 | 위치 |
|------|------|------|
| `project.yml` | Background Modes capability 추가 | 프로젝트 설정 |
| `NotificationManager.swift` | 신규 생성 | `Shared/Services/` |
| `BackgroundTaskManager.swift` | 신규 생성 | `InspireMe/Services/` |
| `ToastView.swift` | 신규 생성 | `InspireMe/Views/` |
| `AppGroupManager.swift` | `notificationEnabled`, `notifyRandomQuote` 추가 | `Shared/Services/` |
| `InspireMeApp.swift` | BGTask 등록, 알림 권한, NotificationDelegate 추가 | `InspireMe/` |
| `SettingsView.swift` | 알림 설정 섹션 추가 | `InspireMe/Views/` |
| `WidgetPreviewView.swift` | Toast 연동 | `InspireMe/Views/` |
