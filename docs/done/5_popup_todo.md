# 명언 변경 알림 — Todo 체크리스트

## Phase 1: In-App Toast (방안 C)

- [x] `InspireMe/Views/ToastView.swift` 생성
  - [x] ToastView 컴포넌트 구현 (메시지, 3초 자동 사라짐)
  - [x] ToastModifier + View extension 구현 (`.toast()` modifier)
- [x] `InspireMe/Views/WidgetPreviewView.swift` 수정
  - [x] `@State showToast` 추가
  - [x] `.toast()` modifier 적용
  - [x] 위젯 새로고침 시 토스트 표시
- [x] `xcodegen generate` 실행
- [x] 빌드 및 Toast 동작 확인

## Phase 2: Local Notification + BGAppRefreshTask (방안 A)

### 2-1. 프로젝트 설정

- [x] `project.yml` 수정
  - [x] InspireMe 타겟에 `Background Modes` capability 추가 (`fetch`)
  - [x] Info.plist에 `BGTaskSchedulerPermittedIdentifiers` 추가 (`pe.kr.advenoh.inspireme.quote-refresh`)
- [x] `xcodegen generate` 실행

### 2-2. AppGroupManager 확장

- [x] `Shared/Services/AppGroupManager.swift` 수정
  - [x] `Keys` enum에 `notificationEnabled`, `notifyRandomQuote` 추가
  - [x] `notificationEnabled` computed property 추가 (기본값: true)
  - [x] `notifyRandomQuote` computed property 추가 (기본값: false)

### 2-3. NotificationManager 구현

- [x] `Shared/Services/NotificationManager.swift` 생성
  - [x] `requestAuthorization()` — 알림 권한 요청
  - [x] `isAuthorized()` — 권한 상태 확인
  - [x] `scheduleQuoteNotification(quote:)` — Local Notification 발송
  - [x] `removeAllPending()` — 대기 알림 제거
  - [x] 알림 content에 quoteURL userInfo 포함 (Deep Link용)
  - [x] 다국어 알림 제목 처리 (ko/en)

### 2-4. BackgroundTaskManager 구현

- [x] `InspireMe/Services/` 디렉토리 생성
- [x] `InspireMe/Services/BackgroundTaskManager.swift` 생성
  - [x] `registerTask()` — BGAppRefreshTask 등록
  - [x] `scheduleAppRefresh()` — 다음 실행 예약
  - [x] `handleAppRefresh(task:)` — API fetch → 캐시 비교 → 알림 발송
  - [x] `expirationHandler`에서 Task 취소 처리

### 2-5. 앱 진입점 수정

- [x] `InspireMe/InspireMeApp.swift` 수정
  - [x] `import BackgroundTasks` 추가
  - [x] `init()`에서 `BackgroundTaskManager.registerTask()` 호출
  - [x] `.task`에서 알림 권한 요청 + 백그라운드 스케줄링
  - [x] `NotificationDelegate` 클래스 구현
    - [x] `didReceive response` — 알림 탭 시 Deep Link 처리 (quoteURL → widgetURL)
    - [x] `willPresent notification` — Foreground에서도 배너 표시
  - [x] `UNUserNotificationCenter.current().delegate` 설정

- [x] `xcodegen generate` 실행
- [x] 빌드 확인

## Phase 3: 알림 설정 UI

- [x] `InspireMe/Views/SettingsView.swift` 수정
  - [x] `@State notificationEnabled`, `@State notifyRandomQuote` 추가
  - [x] "알림" Section 추가 (갱신 주기 아래)
    - [x] "명언 변경 알림" Toggle
    - [x] "오늘의 명언" Toggle (항상 켜짐, disabled)
    - [x] "랜덤 명언" Toggle (선택)
  - [x] `onChange` 핸들러 추가 (AppGroupManager 저장 + 권한 요청)
- [x] 빌드 및 설정 UI 확인

## Phase 4: 알림 딥링크 처리

- [x] 알림 탭 → SafariView로 명언 페이지 열기 확인
  - [x] `NotificationDelegate.didReceive` → `widgetURL` 연동
  - [ ] iOS에서 알림 탭 → SafariView fullScreenCover 동작 확인 (실기기 테스트 필요)
  - [ ] macOS에서 알림 탭 → 브라우저 열기 동작 확인 (실기기 테스트 필요)

## Phase 5: 테스트

- [ ] In-App Toast 테스트
  - [ ] 미리보기 탭에서 위젯 새로고침 시 토스트 표시 확인
  - [ ] 3초 후 자동 사라짐 확인
  - [ ] 반복 트리거 시 정상 동작 확인
- [ ] Local Notification 테스트
  - [ ] 알림 권한 요청 팝업 표시 확인
  - [ ] 시뮬레이터에서 BGTask 수동 트리거 테스트
    ```
    e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"pe.kr.advenoh.inspireme.quote-refresh"]
    ```
  - [ ] 명언 변경 시 알림 발송 확인
  - [ ] 명언 미변경 시 알림 미발송 확인
  - [ ] 알림 탭 → 앱 열기 + SafariView 표시 확인
- [ ] 설정 UI 테스트
  - [ ] 알림 끄기 → 알림 미발송 확인
  - [ ] 랜덤 명언 알림 켜기/끄기 동작 확인
- [ ] macOS 테스트
  - [ ] Mac에서 알림 표시 확인
  - [ ] Mac에서 알림 탭 → 브라우저 열기 확인
- [ ] 빌드 확인
  - [ ] `xcodebuild build` iOS 성공
  - [ ] `xcodebuild build` macOS 성공
