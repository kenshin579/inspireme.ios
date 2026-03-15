# InspireMe iOS

[InspireMe](https://inspireme.advenoh.pe.kr) 명언 플랫폼의 iOS/macOS 위젯 앱.
홈 화면, 잠금 화면, 데스크탑에서 명언을 보여주고, 탭하면 InspireMe 웹사이트로 이동합니다.

## 주요 기능

- **오늘의 명언 위젯** — 하루 1개 명언을 고정 표시
- **랜덤 명언 위젯** — 주기적으로 새로운 명언 표시
- **멀티 플랫폼** — iPhone, iPad, Mac 지원
- **다양한 위젯 크기** — Small, Medium, Large, Lock Screen
- **테마 선택** — Gradient, Dark, Warm, Nature, Light
- **탭 동작** — 명언 탭 → 명언 상세 페이지, 저자 탭 → 저자 페이지로 이동

## 기술 스택

| 항목 | 내용 |
|------|------|
| 언어 | Swift 6 (Strict Concurrency) |
| UI | SwiftUI, WidgetKit, AppIntents |
| 최소 버전 | iOS 17+, iPadOS 17+, macOS 14+ (Sonoma) |
| 백엔드 | InspireMe Widget API |
| 의존성 | 외부 라이브러리 없음 (Apple 프레임워크만 사용) |

## 프로젝트 구조

```
inspireme.ios/
├── InspireMe/                    # 메인 앱 (설정 화면)
│   ├── InspireMeApp.swift
│   ├── Views/                    # 설정, 미리보기
│   ├── Models/                   # Quote, Author
│   └── Services/                 # API 클라이언트
├── InspireMeWidget/              # WidgetKit Extension
│   ├── InspireMeWidget.swift     # Widget 정의
│   ├── QuoteProvider.swift       # TimelineProvider
│   └── Views/                    # Small, Medium, Large, LockScreen
├── Shared/                       # 앱 ↔ 위젯 공유 코드
└── docs/                         # 문서
    └── start/
        ├── 1_inspire_ios_prd.md  # PRD (기능 명세, 결정 사항)
        └── widget-mockup.html    # UI 목업
```

## 개발 환경

### 필수 요구사항

- Xcode 16+ (Swift 6 지원)
- macOS 14+ (Sonoma)
- Apple Developer 계정 (App Group, WidgetKit Extension 설정에 필요)

### 환경 확인

```bash
# Xcode 설치 확인
xcode-select -p
xcodebuild -version

# 미설치 시 App Store에서 Xcode 설치
```

## 사용 API

InspireMe Widget API를 사용합니다 (인증 불필요).

```
GET /api/widget/quote-of-the-day?lang={ko|en}   # 오늘의 명언
GET /api/widget/random?lang={ko|en}&count=1      # 랜덤 명언
```

## 문서

- [PRD (기능 명세 및 결정 사항)](docs/start/1_inspire_ios_prd.md)
- [UI 목업](docs/start/widget-mockup.html) — 브라우저에서 열어서 확인

## 관련 프로젝트

| 프로젝트 | 설명 |
|---------|------|
| [inspireme.advenoh.pe.kr](https://github.com/kenshin579/inspireme.advenoh.pe.kr) | InspireMe 웹 플랫폼 (Next.js + Go) |
| [app-quotememtum](https://github.com/kenshin579/app-quotememtum) | 명언 Chrome Extension |
