# 우주사과 (woojusagwa) 🍎🚀

**갤럭시 스마트폰의 문자 알림을 macOS로 전달하는 가장 가볍고 확실한 방법**

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20macOS-brightgreen" alt="Platform">
  <img src="https://img.shields.io/badge/Language-Kotlin%20%7C%20Swift-orange" alt="Language">
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="License">
</p>

---

## 📖 소개

**우주사과**는 갤럭시 스마트폰 사용자가 Mac을 사용할 때 문자 메시지 알림을 놓치지 않도록 설계된 오픈소스 프로젝트입니다. 별도의 복잡한 백엔드 서버 없이, 오픈소스 푸시 서비스인 `ntfy`를 활용하여 **보안**과 **속도**를 모두 잡았습니다.

> "갤럭시 문자 알림이 맥에 자연스럽게 뜬다." - 이 목표 하나만을 위해 만들어졌습니다.

---

## ✨ 핵심 기능

- **실시간 문자 전달**: 삼성 메시지 및 구글 메시지 알림을 macOS 알림 센터로 즉시 전달
- **ntfy 기반 설계**: 별도의 회원가입이나 개인정보 저장 없이 오픈소스 릴레이 서버 활용
- **QR 코드 페어링**: Mac 앱에서 생성된 QR 코드를 스마트폰으로 스캔하는 것만으로 설정 완료
- **네이티브 경험**: 각 플랫폼(Android, macOS)의 네이티브 기능을 활용한 최적의 성능과 배터리 효율
- **보안 중심**: 랜덤하게 생성되는 토픽(Topic)을 비밀번호처럼 사용하여 데이터 노출 최소화

---

## 🛠 아키텍처

```mermaid
graph LR
    A[갤럭시 스마트폰] -- 알림 캡처 --> B[Android 앱]
    B -- ntfy Publish --> C((ntfy.sh 서버))
    C -- ntfy Subscribe --> D[macOS 앱]
    D -- 알림 센터 호출 --> E[Mac 알림 표시]
```

---

## 🚀 시작하기

### 1. macOS 설정
1. `macos/` 폴더의 프로젝트를 Xcode로 빌드하거나 배포된 앱을 실행합니다.
2. 메뉴바의 **우주사과 아이콘**을 클릭합니다.
3. **"Show Pairing QR"** 버튼을 눌러 페어링용 QR 코드를 띄웁니다.

### 2. Android 설정
1. `android/` 폴더의 프로젝트를 Android Studio로 빌드하여 스마트폰에 설치합니다.
2. 앱을 실행하고 **"Pair with Mac (Scan QR)"** 버튼을 눌러 Mac의 QR 코드를 스캔합니다.
3. **설정 > 알림 > 알림 접근 권한**에서 `woojusagwa` 앱의 권한을 허용합니다.

---

## 📂 프로젝트 구조

```text
woojusagwa/
 ├─ android/      # Kotlin 기반 Android 앱 (NotificationListener)
 ├─ macos/        # SwiftUI 기반 macOS 메뉴바 앱 (Ntfy Subscriber)
 ├─ contracts/    # 플랫폼 간 통신 규격 (JSON Schema)
 ├─ docs/         # 설계 문서 및 PDCA 개발 기록
 └─ README.md     # 프로젝트 메인 가이드
```

---

## 🛡 보안 및 개인정보

- 본 프로젝트는 메시지 내용을 어떠한 서버에도 저장하지 않습니다.
- 모든 데이터는 `ntfy.sh`를 통해 전달되며, 토픽 이름이 유출되지 않는 한 안전합니다.
- 민감한 개인 정보 보호를 위해 로컬 로그에는 메시지 본문을 남기지 않습니다.

---

## 🤝 기여하기

버그 제보나 기능 제안은 언제나 환영합니다! Issue를 생성하거나 Pull Request를 보내주세요.

---

## ⚖️ 라이선스

이 프로젝트는 [MIT License](./LICENSE)를 따릅니다.

---

<p align="center">
  <b>parkjangwon (vim@kakao.com)</b>
</p>
