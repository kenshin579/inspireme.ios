# InspireMe iOS 위젯 앱 — TODO

## Phase 0: 개발 환경 확인

- [ ] Xcode 설치 확인 (`xcode-select -p`, `xcodebuild -version`)
- [ ] 미설치 시 App Store에서 Xcode 16+ 설치
- [ ] iOS Simulator 확인 (iPhone, iPad 시뮬레이터 다운로드)
- [ ] Apple Developer 계정 확인 (Widget Extension + App Group 설정에 필요)

---

## Phase 1: 백엔드 API 수정

- [ ] Widget API 응답 DTO에 `authorSlug` 필드 추가
  - [ ] `/api/widget/random` 응답에 반영
  - [ ] `/api/widget/quote-of-the-day` 응답에 반영
- [ ] 백엔드 테스트 작성 및 확인
- [ ] 배포

---

## Phase 2: Xcode 프로젝트 셋업

- [ ] Xcode 프로젝트 생성 (SwiftUI App)
  - [ ] Swift 6 Language Mode 설정
  - [ ] Deployment Target: iOS 17.0, macOS 14.0
- [ ] WidgetKit Extension 타겟 추가
  - [ ] Destinations: iPhone, iPad, Mac
- [ ] App Group 설정 (`group.pe.kr.advenoh.inspireme`)
  - [ ] 메인 앱 타겟에 App Group capability 추가
  - [ ] 위젯 Extension 타겟에 App Group capability 추가
- [ ] CLAUDE.md 작성 (빌드/테스트/린트 커맨드)

---

## Phase 3: 공유 모듈 구현

- [ ] 모델 정의
  - [ ] `Quote` — id, content, author, authorSlug, language, topics, tags
  - [ ] `QuoteResponse` / `QuotesResponse` — API 응답 래퍼
- [ ] API 클라이언트 (`InspireMeAPI`)
  - [ ] `fetchQuoteOfTheDay(lang:)` 구현
  - [ ] `fetchRandomQuote(lang:topics:)` 구현
  - [ ] 에러 처리 (네트워크 실패 → 캐시 fallback)
- [ ] AppGroupManager
  - [ ] 설정값 저장/로드 (언어, 갱신주기, 테마, 토픽필터, 다크모드)
  - [ ] 캐시된 명언 저장/로드 (오프라인 fallback용)
- [ ] 테마 시스템 (`WidgetTheme`)
  - [ ] 5가지 테마 정의 (Gradient, Dark, Warm, Nature, Light)
  - [ ] 각 테마별 background, textColor, accentColor

---

## Phase 4: 위젯 구현

### 오늘의 명언 위젯

- [ ] `QuoteOfTheDayProvider` (TimelineProvider)
  - [ ] `getTimeline` — API 호출, 다음 자정까지 유효한 Timeline 생성
  - [ ] `getSnapshot` — 캐시 또는 placeholder 반환
  - [ ] API 실패 시 캐시 fallback
- [ ] `QuoteOfTheDayWidget` 정의 (supportedFamilies: small, medium, large, lockscreen)

### 랜덤 명언 위젯

- [ ] `RandomQuoteProvider` (TimelineProvider)
  - [ ] `getTimeline` — 설정된 갱신 주기(1h/4h/24h) 기반 Timeline 생성
  - [ ] AppGroupManager에서 언어/토픽 필터 읽기
  - [ ] API 실패 시 캐시 fallback
- [ ] `RandomQuoteWidget` 정의

### WidgetBundle

- [ ] `InspireMeWidgetBundle` — 2종 위젯 등록

### 위젯 뷰

- [ ] `SmallQuoteView` — 명언 + 저자, 전체 탭 → `/quotes/{id}`
- [ ] `MediumQuoteView` — 명언/저자 영역 분리 탭, 새로고침 버튼
- [ ] `LargeQuoteView` — 명언 + 저자 + 토픽 태그 + 새로고침 버튼
- [ ] `LockScreenQuoteView` — Rectangular, Circular, Inline 3종
- [ ] 각 뷰에 테마 적용
- [ ] 다크 모드 대응 (`@Environment(\.colorScheme)`)

### Deep Link

- [ ] Small: 위젯 전체 `Link` → `https://inspireme.advenoh.pe.kr/quotes/{id}`
- [ ] Medium/Large: 명언 영역 → `/quotes/{id}`, 저자 영역 → `/authors/{slug}`

### Interactive Widget

- [ ] `RefreshQuoteIntent` (AppIntent) — Timeline 리로드
- [ ] Medium/Large 위젯에 새로고침 버튼 추가

---

## Phase 5: 메인 앱 구현

- [ ] 온보딩 화면 (첫 실행 시 위젯 추가 안내)
- [ ] 위젯 미리보기 화면 (현재 설정 기반)
- [ ] 설정 화면
  - [ ] 언어 선택 (한국어 / English)
  - [ ] 갱신 주기 (1시간 / 4시간 / 하루)
  - [ ] 테마 선택 (5가지 + 미리보기)
  - [ ] 다크 모드 (시스템 / 다크 / 라이트)
  - [ ] 토픽 필터 (토글 방식)
- [ ] 설정 변경 시 `WidgetCenter.shared.reloadAllTimelines()` 호출

---

## Phase 6: 테스트 & QA

- [ ] iPhone 시뮬레이터에서 위젯 동작 확인 (Small, Medium, Large)
- [ ] iPad 시뮬레이터에서 위젯 동작 확인
- [ ] Mac (Designed for iPad / Mac Catalyst) 위젯 확인
- [ ] Lock Screen 위젯 확인 (Rectangular, Circular, Inline)
- [ ] StandBy 모드에서 폰트 크기/레이아웃 확인
- [ ] 오프라인 상태에서 캐시 fallback 동작 확인
- [ ] 명언 탭 → Safari 이동 확인
- [ ] 저자 탭 → Safari 이동 확인
- [ ] 새로고침 버튼 동작 확인
- [ ] 테마 변경 → 위젯 즉시 반영 확인
- [ ] 다크/라이트 모드 전환 확인

---

## Phase 7: 배포

- [ ] App Store Connect 설정
- [ ] TestFlight 배포 및 테스트
- [ ] App Store 심사 제출
