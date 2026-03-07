# 우주사과 (woojusagwa) 🍎🚀

<div align="center">
  <p>
    <strong>한국어</strong> | 
    <a href="./README.en.md">English</a>
  </p>
</div>

**갤럭시폰의 문자 알림을 Mac으로 자연스럽게 이어주는, 가장 작은 네이티브 브리지**

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20macOS-brightgreen" alt="Platform">
  <img src="https://img.shields.io/badge/Language-Kotlin%20%7C%20Swift-orange" alt="Language">
  <img src="https://img.shields.io/badge/License-MIT-blue" alt="License">
</p>

---

## 📖 소개

**우주사과**는 갤럭시 스마트폰을 쓰지만 Mac을 사랑하는 사람들을 위한 오픈소스 프로젝트입니다. 안드로이드와 macOS 사이에 거대한 동기화 플랫폼을 끼워 넣지 않고, 문자 알림 하나를 빠르고 조용하게 이어주는 데만 집중합니다.

> "갤럭시 문자 알림이 Mac에 네이티브하게 뜬다."  
> 우주사과는 이 한 문장을 제품 요구사항처럼 다룹니다.

## 🍎 왜 우주사과인가

- **작아야 합니다**: 계정, 클라우드, 대시보드, 분석 시스템 없이 동작해야 합니다.
- **네이티브여야 합니다**: Android는 `NotificationListenerService`, macOS는 메뉴바와 알림 센터를 씁니다.
- **너드 친화적이어야 합니다**: 무엇이 어디로 전달되는지 설명 가능해야 하고, 숨은 백엔드가 없어야 합니다.
- **사생활을 침범하지 않아야 합니다**: 토픽은 비밀처럼 취급하고, 메시지 본문은 불필요하게 저장하지 않습니다.

## 👩‍💻 누구를 위한가

- 갤럭시폰은 포기하고 싶지 않지만 Mac 위에서 일하는 사람
- "동기화 플랫폼"보다 작은 유틸리티를 선호하는 사람
- 직접 빌드하고 구조를 이해하는 것을 즐기는 사람
- 메시지 알림 하나 때문에 개인정보를 다른 서버에 더 넘기고 싶지 않은 사람

---

## ✨ 핵심 기능

- **실시간 문자 전달**: 삼성 메시지 및 구글 메시지 알림을 macOS 알림 센터로 즉시 전달
- **ntfy 기반 설계**: 별도의 회원가입이나 개인정보 저장 없이 오픈소스 릴레이 서버 활용
- **QR 코드 페어링**: Mac 앱에서 생성된 QR 코드를 스마트폰으로 스캔하는 것만으로 설정 완료
- **네이티브 경험**: 각 플랫폼(Android, macOS)의 네이티브 기능을 활용한 최적의 성능과 배터리 효율
- **보안 중심**: 랜덤하게 생성되는 토픽(Topic)을 비밀번호처럼 사용하여 데이터 노출 최소화
- **빠른 확인과 복사**: macOS 메뉴바에서 마지막으로 받은 메시지를 바로 확인하고 복사

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
1. `macos/Woojusagwa/` 프로젝트를 Xcode로 열어 빌드하거나 배포된 앱을 실행합니다.
2. 메뉴바의 **우주사과 아이콘**을 클릭합니다.
3. **"새 페어링 QR 만들기"** 버튼을 눌러 Mac 전용 비밀 토픽이 담긴 QR 코드를 띄웁니다.

### 2. Android 설정
1. `android/` 폴더의 프로젝트를 Android Studio로 빌드하여 스마트폰에 설치합니다.
2. 앱을 실행하고 **"Mac과 페어링하기 (QR 스캔)"** 버튼을 눌러 Mac의 QR 코드를 스캔합니다.
3. **설정 > 알림 > 알림 접근 권한**에서 `woojusagwa` 앱의 권한을 허용합니다.

### 3. 확인
1. Android에서 본인에게 테스트 문자를 보내거나 기존 문자 알림을 기다립니다.
2. Mac 메뉴바 앱의 상태가 **Receiving messages**로 바뀌고, 마지막 수신 메시지가 표시되는지 확인합니다.

---

## 📂 프로젝트 구조

```text
woojusagwa/
 ├─ android/      # Kotlin 기반 Android 앱 (NotificationListener)
 ├─ macos/        # SwiftUI 기반 macOS 메뉴바 앱 (Ntfy Subscriber)
 ├─ contracts/    # 플랫폼 간 통신 규격 (JSON Schema)
 ├─ docs/         # 설계 문서 및 PDCA 개발 기록
 └─ README.md     # 프로젝트 메인 가이드 (한국어)
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
