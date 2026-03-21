# InspireMe iOS 위젯 앱 — 구현 문서

## 1. 백엔드 API 수정

### Widget API 응답에 `authorSlug` 추가

**대상 파일**: `inspireme.advenoh.pe.kr/backend/pkg/widget/handler.go` (또는 관련 DTO)

Widget API 응답에 `authorSlug` 필드를 추가한다. 위젯에서 저자 페이지 링크(`/authors/{slug}`) 생성에 필요.

**변경할 응답 구조**:
```json
{
  "data": {
    "id": "uuid",
    "content": "명언 텍스트",
    "author": "저자 이름",
    "authorSlug": "author-slug",   // ← 추가
    "language": "ko",
    "topics": ["motivation", "life"],
    "tags": ["tag1"]
  }
}
```

**영향 범위**: `/api/widget/random`, `/api/widget/quote-of-the-day` 두 엔드포인트 모두 적용

---

## 2. Xcode 프로젝트 구성

### 타겟 구성

| 타겟 | 유형 | Destinations | 설명 |
|------|------|-------------|------|
| InspireMe | App | iPhone, iPad, Mac | 메인 앱 (설정 화면) |
| InspireMeWidget | Widget Extension | iPhone, iPad, Mac | 위젯 |
| Shared | Framework (또는 타겟 멤버십 공유) | - | 공유 코드 (모델, API, AppGroup) |

### 프로젝트 설정

- **Swift Language Version**: 6 (`SWIFT_STRICT_CONCURRENCY = complete`)
- **Deployment Target**: iOS 17.0, macOS 14.0
- **App Group**: `group.pe.kr.advenoh.inspireme` (앱 ↔ 위젯 데이터 공유용)
- **외부 의존성**: 없음

---

## 3. 공유 모듈 (Shared)

### 3.1 모델

```swift
// Quote.swift
struct Quote: Codable, Sendable {
    let id: String
    let content: String
    let author: String
    let authorSlug: String
    let language: String
    let topics: [String]
    let tags: [String]?
}

struct QuoteResponse: Codable, Sendable {
    let data: Quote       // 단일
}

struct QuotesResponse: Codable, Sendable {
    let data: [Quote]     // 복수
}
```

### 3.2 API 클라이언트

```swift
// InspireMeAPI.swift
actor InspireMeAPI {
    static let baseURL = "https://inspireme.advenoh.pe.kr"

    // 오늘의 명언
    func fetchQuoteOfTheDay(lang: String = "ko") async throws -> Quote

    // 랜덤 명언
    func fetchRandomQuote(lang: String = "ko", topics: [String]? = nil) async throws -> Quote
}
```

- `URLSession` 사용 (외부 라이브러리 없음)
- `async/await` + `Sendable` 준수
- 에러 처리: 네트워크 실패 시 캐시된 명언 반환

### 3.3 App Group 설정 관리

```swift
// AppGroupManager.swift
struct AppGroupManager {
    static let suiteName = "group.pe.kr.advenoh.inspireme"

    // 저장할 설정값
    var language: String          // "ko" | "en"
    var refreshInterval: Int      // 1, 4, 24 (시간)
    var widgetTheme: String       // "gradient" | "dark" | "warm" | "nature" | "light"
    var selectedTopics: [String]  // 토픽 필터
    var colorSchemeMode: String   // "system" | "dark" | "light"

    // 캐시된 명언 (오프라인 fallback용)
    var cachedQuote: Quote?
}
```

`UserDefaults(suiteName:)`로 앱 ↔ 위젯 간 데이터 공유.

---

## 4. 위젯 (InspireMeWidget)

### 4.1 위젯 구성

WidgetBundle로 2종 위젯 제공:

```swift
@main
struct InspireMeWidgetBundle: WidgetBundle {
    var body: some Widget {
        QuoteOfTheDayWidget()   // 오늘의 명언
        RandomQuoteWidget()     // 랜덤 명언
    }
}
```

### 4.2 TimelineProvider

**오늘의 명언 (QuoteOfTheDayProvider)**:
- `getTimeline`: API 호출 → 다음 자정까지 유효한 Timeline 1개 생성
- `getSnapshot`: 캐시된 명언 또는 placeholder 반환

**랜덤 명언 (RandomQuoteProvider)**:
- `getTimeline`: API 호출 → 설정된 갱신 주기(1h/4h/24h) 후 갱신되는 Timeline 생성
- AppGroupManager에서 갱신 주기, 언어, 토픽 필터 읽기

**공통**:
- API 실패 시 → `AppGroupManager.cachedQuote` 반환 (오프라인 fallback)
- API 성공 시 → 캐시 갱신

### 4.3 위젯 뷰

| 크기 | 파일 | 구현 내용 |
|------|------|----------|
| Small | `SmallQuoteView` | 명언 + 저자. 위젯 전체가 `Link`로 `/quotes/{id}` 이동 |
| Medium | `MediumQuoteView` | 명언 영역 → `/quotes/{id}`, 저자 영역 → `/authors/{slug}`. 새로고침 버튼 (AppIntent) |
| Large | `LargeQuoteView` | 명언 + 저자 + 토픽 태그 + 새로고침 버튼. "오늘의 명언" 라벨 표시 |
| Lock Screen | `LockScreenQuoteView` | Rectangular: 명언 + 저자. Circular: ❝ 아이콘. Inline: 명언 발췌 |

### 4.4 Deep Link

위젯 탭 시 URL Scheme이 아닌 **Universal Link** 방식으로 Safari 이동:

```swift
// Small 위젯 — 전체 탭
Link(destination: URL(string: "\(InspireMeAPI.baseURL)/quotes/\(quote.id)")!) {
    SmallQuoteContent(quote: quote)
}

// Medium/Large 위젯 — 영역별 탭
Link(destination: URL(string: "\(InspireMeAPI.baseURL)/quotes/\(quote.id)")!) {
    QuoteContentArea(quote: quote)
}
Link(destination: URL(string: "\(InspireMeAPI.baseURL)/authors/\(quote.authorSlug)")!) {
    AuthorNameArea(author: quote.author)
}
```

### 4.5 Interactive Widget (새로고침)

```swift
// RefreshQuoteIntent.swift
struct RefreshQuoteIntent: AppIntent {
    static var title: LocalizedStringResource = "새로고침"

    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadTimelines(ofKind: "RandomQuoteWidget")
        return .result()
    }
}
```

Medium/Large 위젯에 `Button(intent: RefreshQuoteIntent())` 추가.

---

## 5. 테마 시스템

5가지 테마를 SwiftUI Gradient/Color 조합으로 구현:

```swift
enum WidgetTheme: String, CaseIterable, Codable {
    case gradient  // 보라색 그라데이션 (기본)
    case dark      // 다크 엘레건트
    case warm      // 따뜻한 브라운
    case nature    // 자연 그린
    case light     // 라이트

    var background: some ShapeStyle { ... }
    var textColor: Color { ... }
    var accentColor: Color { ... }
}
```

다크 모드 대응:
- `@Environment(\.colorScheme)` 감지
- 설정: "시스템 따라가기 / 항상 다크 / 항상 라이트"
- Light 테마 선택 시 다크 모드에서도 밝은 배경 유지 (사용자 선택 우선)

---

## 6. 메인 앱 (InspireMe)

### 화면 구성

| 화면 | 설명 |
|------|------|
| 온보딩 | 첫 실행 시 위젯 추가 안내 (Apple 심사 대응) |
| 위젯 미리보기 | 현재 설정 기반으로 위젯 모양 미리보기 |
| 설정 | 언어, 갱신 주기, 위젯 유형, 테마, 다크 모드, 토픽 필터 |

### 설정 항목

| 설정 | 옵션 | 기본값 |
|------|------|--------|
| 언어 | 한국어 / English | 한국어 |
| 갱신 주기 | 1시간 / 4시간 / 하루 | 4시간 |
| 테마 | Gradient / Dark / Warm / Nature / Light | Gradient |
| 다크 모드 | 시스템 / 다크 / 라이트 | 시스템 |
| 토픽 필터 | 동기부여, 행복, 사랑, 성공 등 토글 | 전체 선택 |

설정 변경 시 `WidgetCenter.shared.reloadAllTimelines()` 호출하여 위젯 즉시 갱신.
