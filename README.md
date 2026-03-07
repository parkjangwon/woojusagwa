# woojusagwa (우주사과)

Galaxy SMS → Mac notification relay.

우주사과는 **갤럭시 스마트폰의 문자 알림을 macOS로 전달하는 최소 기능 앱**입니다.

목표는 단 하나입니다.

> 갤럭시 문자 알림이 맥에 자연스럽게 뜬다.

---

# 핵심 기능

- Galaxy SMS notification → macOS forwarding
- ntfy 기반 푸시 전달
- QR 기반 페어링
- macOS 알림 표시
- macOS에서 알림 텍스트 복사

---

# 아키텍처

```
Galaxy Android
│
NotificationListener
│
ntfy publish
│
ntfy server
│
Mac subscribe
│
macOS notification
```

---

# 리포 구조

```
woojusagwa
├─ android
├─ macos
├─ contracts
├─ docs
├─ AGENT.md
└─ README.md
```

---

# 기술 스택

## Android

- Kotlin
- package: `org.parkjw.woojusagwa`
- NotificationListenerService
- QR Scanner
- ntfy HTTP publish

## macOS

- Swift
- SwiftUI
- Menubar app
- ntfy subscribe
- macOS Notification API

---

# 페어링 방식

1. Mac 앱 실행
2. QR 코드 생성
3. Android 앱에서 QR 스캔
4. ntfy 설정 저장
5. 테스트 메시지 전송

---

# ntfy 사용

기본 서버:

```
[https://ntfy.sh](https://ntfy.sh)
```

사용자는 다음을 설정할 수 있습니다.

- server URL
- topic
- optional auth

---

# 보안

- ntfy topic은 **secret**처럼 취급합니다.
- topic은 랜덤 생성됩니다.
- 민감한 알림 내용은 로그에 기록하지 않습니다.

---

# Android 지원 메시지 앱

초기 지원:

- Samsung Messages
- Google Messages

---

# 개발 원칙

- 기능 최소화
- 네이티브 우선
- 유지보수 쉬움
- 명확한 코드
- 계약 기반 개발

---

# 개발 실행

## Android

```
open android/ in Android Studio
```

패키지:

```
org.parkjw.woojusagwa
```

---

## macOS

```
open macos/ in Xcode
```

---

# 프로젝트 상태

MVP 단계

목표:

- 안정적인 문자 알림 전달
- 최소 UI
- 유지보수 쉬운 코드
