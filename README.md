# 우주사과

<div align="center">
  <p>
    <strong>한국어</strong> |
    <a href="./README.en.md">English</a>
  </p>
</div>

**갤럭시폰 문자 알림을 Mac 알림센터로 이어주는 가장 작은 네이티브 브리지**

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20macOS-5b8cff" alt="Platform">
  <img src="https://img.shields.io/badge/Release-1.0.0-1f7a3f" alt="Release">
  <img src="https://img.shields.io/badge/License-MIT-4c566a" alt="License">
</p>

## 우주사과가 하는 일

우주사과는 갤럭시폰에서 들어온 SMS 알림을 Mac의 네이티브 알림센터로 전달합니다.

- 안드로이드는 문자 알림을 읽고
- `ntfy` 토픽으로 밀어 넣고
- 각 Mac은 자기 전용 토픽을 구독해서
- macOS 알림센터 배너와 목록으로 보여줍니다

계정도 없고, 별도 백엔드도 없고, 대시보드도 없습니다.  
우주사과는 "갤럭시 문자 알림이 Mac에 뜬다"라는 한 가지 목적만 다룹니다.

## 철학

- 작아야 합니다: 로그인, 클라우드 동기화, 분석 시스템 없이 끝나야 합니다.
- 네이티브여야 합니다: Android는 알림 접근 권한, macOS는 메뉴바와 알림센터를 씁니다.
- 설명 가능해야 합니다: 갤럭시 1대가 Mac N대로 fan-out 되는 구조를 사용합니다.
- 사생활을 덜 건드려야 합니다: 토픽은 비밀값처럼 취급하고, 서버에 별도 계정 데이터를 두지 않습니다.

## 누구를 위한 도구인가

- 갤럭시폰은 계속 쓰고 싶지만 업무는 Mac에서 하는 사람
- 거대한 "연동 플랫폼"보다 작은 네이티브 유틸리티를 선호하는 사람
- relay 경로와 저장 위치를 직접 이해하고 싶은 사람
- OTP나 문자 확인을 위해 핸드폰을 계속 집지 않으려는 사람

## 현재 기능

- Galaxy SMS 알림을 macOS 알림센터로 전달
- macOS 메뉴바에서 연결 상태, 마지막 수신 메시지, 현재 토픽 확인
- OTP 감지 시 macOS 알림에 `복사하기` 액션 제공
- 한국어, 영어 UI 전환 지원
- 갤럭시 1대 -> Mac 여러 대 동시 전달
- Android에서 연결된 Mac 켜기/끄기/삭제
- Mac에서 새 페어링 QR 생성으로 개별 토픽 재발급

OTP 감지는 현재 한국어, 영어, 일본어, 중국어 메시지 키워드를 기준으로 동작합니다.

## 멀티 Mac 동작 방식

우주사과는 **갤럭시 1대 + Mac N대** 모델입니다.

- 각 Mac은 자기만의 `device_id`, `device_name`, `topic`을 가집니다.
- Mac 메뉴바 앱에서 QR을 만들면 그 Mac 전용 정보가 들어갑니다.
- Android 앱은 스캔된 Mac 목록을 저장합니다.
- 문자 알림 1건이 오면 Android 앱이 활성화된 Mac 전부에 fan-out 전송합니다.

예시:

- 집 MacBook Pro
- 회사 MacBook Air

둘 다 연결되어 있으면 같은 문자 알림이 두 Mac에 모두 갑니다.

중요한 점:

- Android에서 Mac을 삭제하면 그 Mac으로 **더 이상 보내지 않게만** 됩니다.
- `ntfy` 서버에서 토픽 자체를 지우지는 않습니다.
- 완전한 토픽 교체가 필요하면 Mac에서 `새 페어링 QR 만들기`를 누르면 됩니다.

## 설치 파일

공식 GitHub Release에는 보통 아래 두 파일이 올라갑니다.

- `app-release.apk`: Android 설치 파일
- `woojusagwa-macos-arm64.dmg`: macOS 설치 이미지

`v1.0.0`부터 Android APK는 **고정 release keystore로 서명된 APK**를 기준으로 배포합니다.  
그래서 같은 서명 계열의 다음 버전 APK로 정상 업데이트가 가능합니다.

## 빠른 시작

### 1. macOS 앱 설치

1. GitHub Release에서 `woojusagwa-macos-arm64.dmg`를 내려받습니다.
2. DMG를 열고 `우주사과.app`을 `Applications`로 드래그합니다.
3. 반드시 `/Applications/우주사과.app`를 실행합니다.
4. 메뉴바에 우주사과 아이콘이 뜨면 클릭합니다.
5. 처음 실행 시 macOS 알림 권한을 허용합니다.

권장:

- `시스템 설정 > 알림 > 우주사과`에서 배너와 알림센터 표시를 켜세요.
- DMG 안에서 바로 실행하지 말고, Applications로 복사해서 실행하세요.

### 2. Android 앱 설치

1. GitHub Release에서 `app-release.apk`를 내려받아 설치합니다.
2. 우주사과 앱을 엽니다.
3. `알림 접근 권한 열기`를 눌러 Android 알림 접근 권한 화면으로 이동합니다.
4. `우주사과`를 허용합니다.

지원 대상은 문자 알림입니다.

- 삼성 메시지
- Google Messages

### 3. 첫 페어링

1. Mac 메뉴바 앱에서 `새 페어링 QR 만들기`를 누릅니다.
2. Android 앱에서 `Mac과 페어링하기 (QR 스캔)`을 누릅니다.
3. QR을 스캔합니다.
4. Android 앱의 `연결된 Mac` 목록에 새 Mac이 보이면 완료입니다.

Mac을 여러 대 연결하려면 각 Mac에서 같은 과정을 반복하면 됩니다.

### 4. 동작 확인

1. 갤럭시폰으로 테스트 문자를 받습니다.
2. Mac 메뉴바 상태가 수신 중 상태로 바뀌는지 봅니다.
3. macOS 알림센터에 배너가 뜨는지 확인합니다.
4. OTP 문자인 경우 `복사하기` 버튼이 보이는지 확인합니다.

## 권한 설정 가이드

### Android

우주사과는 문자 내용을 직접 읽는 앱이 아닙니다.  
문자 앱이 띄운 **알림**을 읽습니다.

필요한 권한:

- 알림 접근 권한

설정 경로:

- `설정 > 알림 > 알림 접근 권한`

여기서 `우주사과`를 허용하면 됩니다.

### macOS

우주사과는 수신한 내용을 메뉴바와 알림센터에 보여줍니다.

필요한 권한:

- 알림 허용

설정 경로:

- `시스템 설정 > 알림 > 우주사과`

여기서 아래 항목을 켜는 것을 권장합니다.

- 알림 허용
- 알림센터 표시
- 배너 또는 알림 스타일

## 문제 해결

### macOS 알림이 안 뜰 때

확인 순서:

1. `우주사과.app`를 `/Applications`에서 실행했는지 확인
2. 메뉴바 앱 상태가 `알림 권한 필요`인지 확인
3. `시스템 설정 > 알림 > 우주사과`에서 허용 여부 확인
4. 집중 모드가 켜져 있지 않은지 확인
5. 메뉴바의 `테스트 알림`으로 알림센터 동작 확인

### Android에서 Mac이 안 보일 때

- QR을 다시 스캔해 보세요.
- 이미 같은 Mac을 스캔한 경우 `device_id` 기준으로 기존 정보가 갱신됩니다.
- Mac에서 `새 페어링 QR 만들기`를 누르면 새 토픽으로 갈아탈 수 있습니다.

### APK 업데이트 설치가 안 될 때

업데이트 설치에는 아래 두 가지가 같아야 합니다.

- `applicationId`
- APK 서명 인증서

`v1.0.0`부터 공식 릴리스 APK는 고정 release keystore로 서명됩니다.  
그 이전 debug APK나 로컬 debug APK에서 넘어오는 경우에는 같은 서명이 아니어서 업데이트 설치가 되지 않을 수 있습니다. 그런 경우 한 번 삭제 후 `app-release.apk` 계열로 다시 설치하면 이후 버전부터는 업데이트가 쉬워집니다.

## 저장과 보안

- 메시지 본문을 위한 별도 백엔드 저장소는 없습니다.
- Android는 연결된 Mac 목록과 토픽 정보를 로컬에 저장합니다.
- macOS는 자기 Mac의 페어링 정보와 최근 상태를 로컬에 저장합니다.
- 토픽 문자열은 사실상 비밀키처럼 다뤄야 합니다.

우주사과는 개인정보 시스템이 아니라 relay 기반의 작은 유틸리티입니다.  
그래서 "어디에 저장되는가"와 "어떻게 지우는가"가 비교적 단순합니다.

## 개발 환경

### Android

- Android Studio
- JDK 17
- Android SDK 34

### macOS

- Xcode 15 이상 권장
- Apple Silicon Mac 기준 빌드 검증

## 로컬 빌드

### Android

```bash
cd android
./gradlew --no-daemon testDebugUnitTest assembleRelease
```

### macOS Core 테스트

```bash
cd macos/WoojusagwaCore
swift test
```

### macOS 앱 빌드

```bash
xcodebuild -project macos/Woojusagwa/Woojusagwa.xcodeproj \
  -scheme Woojusagwa \
  -configuration Release \
  -derivedDataPath macos/build \
  -destination 'platform=macOS,arch=arm64' \
  CODE_SIGNING_ALLOWED=NO
```

## 릴리스 유지보수 메모

Android 업데이트 가능한 APK를 배포하려면 같은 release keystore를 계속 써야 합니다.

GitHub Actions는 아래 시크릿을 사용합니다.

- `ANDROID_SIGNING_KEYSTORE_BASE64`
- `ANDROID_SIGNING_STORE_PASSWORD`
- `ANDROID_SIGNING_KEY_ALIAS`
- `ANDROID_SIGNING_KEY_PASSWORD`

릴리스 태그 규칙:

- `dev-*`: 프리릴리스
- `v*`: 정식 릴리스

## 저장소 구조

```text
woojusagwa/
├─ android/      # Android 앱
├─ macos/        # macOS 메뉴바 앱
├─ contracts/    # QR payload / relay message schema
├─ docs/         # 설계와 계획 문서
└─ assets/       # 로고와 기타 정적 자산
```

## 라이선스

[MIT License](./LICENSE)
