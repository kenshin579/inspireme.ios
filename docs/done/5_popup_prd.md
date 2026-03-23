# 명언 변경 알림 (Notification/Toast) PRD

## 1. 배경 및 목적

현재 InspireMe iOS 위젯 앱은 WidgetKit Timeline 기반으로 명언을 자동 갱신하지만, **사용자가 새로운 명언이 변경되었는지 인지할 방법이 없다**. 위젯을 직접 확인하지 않으면 명언이 변경된 사실을 알 수 없다.

**목표**: 명언이 변경될 때 사용자에게 알림(Notification)이나 인앱 토스트(Toast)를 제공하여, 새로운 명언을 놓치지 않도록 한다.

## 2. 현재 아키텍처 분석

### 현재 명언 갱신 흐름

```
WidgetKit Timeline → API Fetch → Quote 캐시 (AppGroupManager) → 위젯 UI 갱신
```

### 현재 한계

| 항목 | 현재 상태 |
|------|----------|
| Push Notification | 미구현 |
| Local Notification | 미구현 |
| In-App Toast | 미구현 |
| Background App Refresh | 미사용 |
| 알림 권한 요청 | 없음 |

### 핵심 제약사항

- **WidgetKit Extension은 `UNUserNotificationCenter` API 사용 불가** — 위젯 Extension 프로세스에서는 Local Notification을 직접 스케줄링할 수 없음
- 위젯 Extension과 메인 앱은 별도 프로세스로 실행됨
- App Group UserDefaults를 통해서만 데이터 공유 가능

## 3. 기술적 가능성 분석

### 방안 A: Local Notification + Background App Refresh (권장)

**원리**: 메인 앱이 백그라운드에서 주기적으로 깨어나, 새 명언을 가져오고 Local Notification을 발송한다.

```
[BGAppRefreshTask] → API Fetch → 이전 캐시와 비교 → 변경 시 Local Notification 발송
```

| 항목 | 내용 |
|------|------|
| 가능 여부 | **가능** |
| 필요 Capability | `Background Modes` → `Background fetch` |
| 알림 권한 | `UNUserNotificationCenter.requestAuthorization` 필요 |
| 백엔드 변경 | 불필요 |
| 배터리 영향 | 낮음 (시스템이 최적 시점에 실행) |
| 정확도 | 시스템이 실행 시점을 결정하므로 정확한 타이밍 보장 불가 |

**장점**:
- 백엔드 변경 없이 구현 가능
- Apple 프레임워크만 사용 (외부 의존성 없음)
- 구현 복잡도 낮음

**단점**:
- 시스템이 실행 시점을 결정 (지연 가능)
- 앱 사용 패턴에 따라 호출 빈도가 달라짐
- iOS가 저전력 모드에서는 빈도를 크게 줄임

### 방안 B: Push Notification (APNs)

**원리**: 백엔드 서버가 명언 변경 시 APNs를 통해 Push Notification을 전송한다.

```
[Backend Cron] → 명언 변경 감지 → APNs Push → iOS 알림 표시
```

| 항목 | 내용 |
|------|------|
| 가능 여부 | **가능하지만 복잡** |
| 필요 Capability | `Push Notifications` |
| 백엔드 변경 | **필요** (APNs 인증서/키, Push 전송 로직, 디바이스 토큰 관리) |
| 정확도 | 높음 (실시간) |
| 배터리 영향 | 매우 낮음 |

**장점**:
- 실시간 알림 가능
- 가장 정확한 타이밍
- 앱이 종료되어 있어도 알림 수신

**단점**:
- 백엔드 변경 필요 (APNs 인증서 관리, 디바이스 토큰 저장 API, Push 전송 로직)
- Apple Developer 유료 계정 필요 (APNs 인증서)
- 구현 복잡도 높음
- 서버 인프라 추가 필요

### 방안 C: In-App Toast만 (앱 사용 중일 때)

**원리**: 앱이 foreground에 있을 때, 명언 변경을 감지하여 화면 내 토스트 메시지를 표시한다.

```
[App Foreground] → Timer/onChange → 캐시 비교 → Toast 표시
```

| 항목 | 내용 |
|------|------|
| 가능 여부 | **가능** |
| 필요 Capability | 없음 |
| 백엔드 변경 | 불필요 |
| 구현 복잡도 | 매우 낮음 |

**장점**:
- 가장 간단한 구현
- 추가 권한 불필요
- 즉시 구현 가능

**단점**:
- **앱이 foreground에 있을 때만 작동** — 위젯 앱 특성상 앱을 자주 열지 않음
- 실용적 가치가 제한적

## 4. 권장 방안: A + C 조합

### 이유

- **방안 A (Local Notification)**: 앱이 백그라운드/종료 상태에서도 명언 변경 알림 수신
- **방안 C (In-App Toast)**: 앱 사용 중 명언 변경을 즉시 시각적으로 확인
- **방안 B (Push)**: 현재 단계에서는 과도한 인프라 변경 필요. 향후 사용자가 많아지면 고려

## 5. 기능 상세

### 5.1 Local Notification (Background App Refresh)

#### 알림 내용

```
┌─────────────────────────────────────┐
│ InspireMe                      지금  │
│ 📖 새로운 명언이 도착했습니다           │
│ "삶이 있는 한 희망은 있다" — 키케로     │
└─────────────────────────────────────┘
```

#### 동작 흐름

1. 앱 최초 실행 시 알림 권한 요청
2. `BGAppRefreshTask` 등록 (`BGTaskScheduler`)
3. 백그라운드 실행 시:
   - API로 새 명언 가져오기
   - `AppGroupManager.cachedQuote`와 비교
   - 변경 시 Local Notification 스케줄링
   - 캐시 업데이트
4. 알림 탭 → 앱 열기 → 해당 명언 웹페이지로 이동 (Deep Link)

#### 설정 옵션 (SettingsView 추가)

| 설정 항목 | 설명 | 기본값 |
|-----------|------|--------|
| 알림 켜기/끄기 | 명언 변경 알림 on/off | 켜기 |
| 알림 시간대 | 방해 금지 시간 설정 (예: 22시-07시) | 없음 |

### 5.2 In-App Toast

#### 토스트 디자인

```
┌───────────────────────────────────────────┐
│ ✨ 새로운 명언이 위젯에 표시되고 있습니다    │
└───────────────────────────────────────────┘
```

- 화면 상단에 표시, 3초 후 자동 사라짐
- 설정에서 위젯 새로고침 시 표시

## 6. 결정 사항

| 항목 | 결정 | 비고 |
|------|------|------|
| Q1. 알림 빈도 | 하루 최대 1회 (오늘의 명언 변경 시) | 잦은 알림은 사용자가 끄게 만듦 |
| Q2. 알림 대상 위젯 | 오늘의 명언 기본 알림, 랜덤 명언은 설정에서 선택 가능 | |
| Q3. macOS 지원 | iOS + macOS 동시 지원 | `UNUserNotificationCenter` 양 플랫폼 사용 가능, `BGTaskScheduler`는 macOS 13+ |
| Q4. 알림 탭 동작 | 앱 열기 + 해당 명언 웹페이지 열기 (Deep Link) | SafariView로 표시 |
| Q5. 위젯 미사용자 알림 | 독립적으로 동작 — 위젯 없이 알림만 사용 가능 | |

### 구현 우선순위

| 순서 | 항목 | 복잡도 |
|------|------|--------|
| 1 | In-App Toast (방안 C) | 낮음 |
| 2 | Local Notification + BGAppRefreshTask (방안 A) | 중간 |
| 3 | 알림 설정 UI | 낮음 |
| 4 | 알림 딥링크 처리 | 낮음 |

## 7. 참고: iOS 알림 관련 Apple 가이드라인

- 알림 권한은 사용자에게 **명확한 가치를 설명한 후** 요청해야 함 (App Store 심사 기준)
- 과도한 알림은 리젝 사유가 될 수 있음
- `BGAppRefreshTask`는 시스템이 최적 시점을 결정하므로, 정확한 시간 보장 불가
- 사용자가 "앱 백그라운드 새로고침"을 시스템 설정에서 끌 수 있음
