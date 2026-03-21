# InspireMe iOS 위젯 앱 PRD

## 1. 프로젝트 개요

InspireMe 명언 플랫폼의 iOS/macOS 위젯 앱. 홈 화면, 잠금 화면, 데스크탑에서 명언을 보여주고, 탭하면 InspireMe 웹사이트의 해당 페이지로 이동한다.

| 항목 | 내용 |
|------|------|
| 프로젝트명 | inspireme.ios |
| 대상 플랫폼 | iPhone, iPad, Mac (iOS 17+, iPadOS 17+, macOS 14+) |
| 기술 스택 | Swift, SwiftUI, WidgetKit, AppIntents |
| 백엔드 | InspireMe API (`https://inspireme.advenoh.pe.kr`) |
| 레포지토리 | `inspireme.ios/` |

## 2. 핵심 기능

### 2.1 위젯 표시

| 항목 | 설명 |
|------|------|
| 명언 텍스트 | quote `content` 표시 |
| 저자 이름 | quote `author` 표시 |
| 탭 동작 (명언) | `https://inspireme.advenoh.pe.kr/quotes/{id}` 로 이동 |
| 탭 동작 (저자) | `https://inspireme.advenoh.pe.kr/authors/{slug}` 로 이동 |

### 2.2 위젯 크기별 레이아웃

| 크기 | iOS/iPadOS | macOS | 표시 내용 |
|------|-----------|-------|----------|
| Small | ✅ | ✅ | 명언 + 저자 (명언 탭 → 웹 이동) |
| Medium | ✅ | ✅ | 명언 + 저자 (각각 탭 가능) |
| Large | ✅ | ✅ | 명언 + 저자 + 토픽 태그 |
| Lock Screen | ✅ (iPhone) | - | 명언 발췌 (짧은 텍스트) |

### 2.3 데이터 갱신 방식

| 방식 | 설명 |
|------|------|
| 오늘의 명언 | `/api/widget/quote-of-the-day` — 하루 1회 갱신 |
| 랜덤 명언 | `/api/widget/random` — Timeline 기반 주기적 갱신 |
| 갱신 주기 | WidgetKit Timeline으로 설정 (예: 1시간, 4시간, 하루) |

## 3. 사용할 API

기존 Widget API를 그대로 활용한다. 인증 불필요 (IP 기반 rate limit 60req/min).

### 3.1 오늘의 명언

```
GET /api/widget/quote-of-the-day?lang={ko|en}
```

### 3.2 랜덤 명언

```
GET /api/widget/random?lang={ko|en}&count=1&topics={topics}
```

### 3.3 응답 구조 (Widget API)

```json
{
  "data": {
    "id": "uuid",
    "content": "명언 텍스트",
    "author": "저자 이름",
    "authorSlug": "author-slug",
    "language": "ko",
    "topics": ["motivation", "life"],
    "tags": ["tag1"]
  }
}
```

> **결정**: Widget API 응답에 `authorSlug` 필드를 추가한다 (Phase 1 백엔드 작업)

## 4. 앱 구조 (안)

```
inspireme.ios/
├── InspireMe/                    # 메인 앱 (설정 화면)
│   ├── InspireMeApp.swift
│   ├── Views/
│   │   ├── SettingsView.swift    # 언어, 갱신주기, 토픽 필터
│   │   └── QuotePreviewView.swift
│   ├── Models/
│   │   ├── Quote.swift
│   │   └── Author.swift
│   └── Services/
│       └── InspireMeAPI.swift    # API 클라이언트
├── InspireMeWidget/              # WidgetKit Extension
│   ├── InspireMeWidget.swift     # Widget 정의
│   ├── QuoteProvider.swift       # TimelineProvider
│   ├── Views/
│   │   ├── SmallQuoteView.swift
│   │   ├── MediumQuoteView.swift
│   │   ├── LargeQuoteView.swift
│   │   └── LockScreenView.swift
│   └── QuoteEntry.swift          # TimelineEntry
├── Shared/                       # 앱 ↔ 위젯 공유 코드
│   ├── Models/
│   ├── Services/
│   └── AppGroup.swift            # App Group 설정 공유
└── InspireMe.xcodeproj
```

## 5. 작업 목록

> 상세 체크리스트: [1_inspire_ios_todo.md](1_inspire_ios_todo.md)
> 구현 상세: [1_inspire_ios_implementation.md](1_inspire_ios_implementation.md)

| Phase | 내용 | 주요 작업 |
|-------|------|----------|
| 0 | 개발 환경 확인 | Xcode 16+, Simulator, Apple Developer 계정 |
| 1 | 백엔드 API 수정 | Widget API에 `authorSlug` 필드 추가 |
| 2 | Xcode 프로젝트 셋업 | Swift 6, WidgetKit Extension, App Group |
| 3 | 공유 모듈 구현 | 모델, API 클라이언트, AppGroupManager, 테마 |
| 4 | 위젯 구현 | 2종 위젯, 4가지 크기, Deep Link, Interactive |
| 5 | 메인 앱 구현 | 온보딩, 설정, 위젯 미리보기 |
| 6 | 테스트 & QA | 멀티 플랫폼, StandBy, 오프라인, 다크 모드 |
| 7 | 배포 | App Store Connect, TestFlight, 심사 제출 |

## 6. 결정 사항

### 6.1 API 관련

| # | 주제 | 결정 | 비고 |
|---|------|------|------|
| 1 | **authorSlug** | Widget API 응답에 `authorSlug` 필드 추가 | 백엔드 DTO 수정 필요 → Phase 1 작업에 포함 |
| 2 | **인증 방식** | 인증 없이 Widget API 그대로 사용 | 위젯 요청 빈도가 낮아 (하루 6~24회) rate limit 문제 없음 |
| 3 | **rate limit** | 현재 수준 유지 (60req/min), 추후 모니터링 후 대응 | 필요 시 앱 내장 API Key 또는 User-Agent 기반 별도 limit 적용 |

### 6.2 기능 범위

| # | 주제 | 결정 | 비고 |
|---|------|------|------|
| 4 | **위젯 종류** | "오늘의 명언" + "랜덤 명언" 별도 위젯 2개 제공 | WidgetBundle로 한 앱에서 2종 제공 |
| 5 | **Interactive Widget** | 새로고침 버튼만 Phase 1에서 구현, 좋아요는 Phase 2 이후 | Medium/Large 위젯에만 버튼 표시 |
| 6 | **StandBy 모드** | 자동 지원 (별도 작업 불필요) | WidgetKit이 StandBy에서 자동 표시. 폰트 크기 테스트만 진행 |
| 7 | **Live Activity** | 지원하지 않음 | 명언은 실시간 이벤트가 아님. Apple 심사 리젝 위험 |

---

### 6.3 디자인 & UX

| # | 주제 | 결정 | 비고 |
|---|------|------|------|
| 8 | **위젯 디자인** | InspireMe 보라색 그라데이션 기본 + 5가지 테마 옵션 제공 | Gradient(기본), Dark, Warm, Nature, Light |
| 9 | **배경 이미지** | 초기 미사용, Phase 2 이후 선택 옵션으로 검토 | WidgetKit 메모리 제한(30MB) + 가독성 이슈. 그라데이션 배경으로 충분 |
| 10 | **다크 모드** | 지원 (SwiftUI `@Environment(\.colorScheme)` 활용) | "시스템 따라가기 / 항상 다크 / 항상 라이트" 3가지 옵션 |
| 11 | **메인 앱** | 설정 + 위젯 미리보기만 (브라우징 기능 없음) | 명언 탭 → Safari로 InspireMe 사이트 이동. 온보딩 포함하여 Apple 심사 대응 |

### 6.4 기술

| # | 주제 | 결정 | 비고 |
|---|------|------|------|
| 12 | **최소 지원 버전** | iOS 17+ / macOS 14+ (Sonoma) | Interactive Widget, StandBy 등 최신 기능 활용. iOS 17 점유율 90%+ |
| 13 | **Swift 6** | Strict Concurrency 모드 적용 | 신규 프로젝트라 마이그레이션 부담 없음. Xcode 16+ 설정 |
| 14 | **의존성 관리** | SPM + 외부 의존성 0개로 시작 | URLSession, Codable, SwiftUI, WidgetKit 등 Apple 프레임워크로 충분 |
| 15 | **CI/CD** | Phase 1 수동 배포, 안정화 후 Fastlane 도입 | 초기: Xcode Archive → TestFlight. 추후: fastlane scan + pilot |
