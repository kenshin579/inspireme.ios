# InspireMe iOS — CLAUDE.md

## 프로젝트 개요

InspireMe 명언 플랫폼의 iOS 위젯 앱. 홈 화면, 잠금 화면에서 명언을 표시하고 탭하면 InspireMe 웹사이트로 이동.

## 기술 스택

- Swift 6 (Strict Concurrency), SwiftUI, WidgetKit, AppIntents
- iOS 17+, 외부 의존성 없음
- XcodeGen으로 프로젝트 생성

## 빌드 & 실행

```bash
# XcodeGen으로 .xcodeproj 생성 (새 파일 추가 후 필수)
xcodegen generate

# 빌드 (iOS)
xcodebuild build -project InspireMe.xcodeproj -target InspireMe -sdk iphoneos CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY=""

# 위젯 Extension 빌드
xcodebuild build -project InspireMe.xcodeproj -target InspireMeWidgetExtension -sdk iphoneos CODE_SIGNING_ALLOWED=NO CODE_SIGN_IDENTITY=""

# Xcode에서 열기
open InspireMe.xcodeproj
```

## 프로젝트 구조

```
InspireMe/          # 메인 앱 (설정, 온보딩, 위젯 미리보기)
InspireMeWidget/    # WidgetKit Extension (2종 위젯)
Shared/             # 앱 ↔ 위젯 공유 코드 (모델, API, 테마)
project.yml         # XcodeGen 설정
```

## 주요 규칙

- 새 소스 파일 추가 후 반드시 `xcodegen generate` 실행
- App Group: `group.pe.kr.advenoh.inspireme` (앱 ↔ 위젯 데이터 공유)
- Widget API: `https://inspireme.advenoh.pe.kr/api/widget/`
