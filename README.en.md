# Woojusagwa

<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/ff768db0-64da-46bb-9164-7b60c6fa20cb" />

<div align="center">
  <p>
    <a href="./README.md">한국어</a> |
    <strong>English</strong>
  </p>
</div>

**The smallest native bridge for Galaxy SMS notifications on macOS Notification Center**

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20macOS-5b8cff" alt="Platform">
  <img src="https://img.shields.io/badge/Release-1.0.0-1f7a3f" alt="Release">
  <img src="https://img.shields.io/badge/License-MIT-4c566a" alt="License">
</p>

## What It Does

Woojusagwa forwards SMS notifications from a Galaxy phone into the native macOS Notification Center.

- Android reads SMS app notifications
- pushes them through an `ntfy` topic
- each Mac subscribes to its own topic
- macOS shows native notifications and menu bar status

No account system. No private backend. No dashboard.  
The product scope is intentionally narrow: make Galaxy SMS feel native on a Mac.

## Philosophy

- Stay small: no login flow, no cloud sync platform, no analytics.
- Stay native: Android uses notification access, macOS uses menu bar and Notification Center.
- Stay explainable: one Galaxy phone fans out to many Macs in a simple relay path.
- Stay respectful of privacy: topics are treated like secrets and message content is not stored unnecessarily.

## Who It Is For

- Galaxy phone users who spend the day on a Mac
- People who prefer a tiny utility over a big ecosystem
- Developers and nerds who want to inspect the relay path
- Anyone who wants OTP and SMS visibility without constantly picking up the phone

## Current Features

- Forward Galaxy SMS notifications into macOS Notification Center
- Show connection state, latest message, and topic info in the macOS menu bar app
- Add a `Copy` action for OTP-like messages in macOS notifications
- Support Korean and English UI
- Fan out one Galaxy phone to multiple Macs
- Enable, disable, or remove paired Macs from Android
- Rotate a Mac topic by generating a new pairing QR code

OTP detection currently supports Korean, English, Japanese, and Chinese message keywords.

## Multi-Mac Model

Woojusagwa uses a **1 Galaxy phone + N Macs** model.

- Each Mac owns its own `device_id`, `device_name`, and `topic`.
- The Mac app generates a QR code with that device-specific pairing payload.
- The Android app stores a list of paired Macs.
- Every incoming SMS notification is fanned out to every enabled Mac.

Example:

- personal MacBook Pro at home
- work MacBook Air

If both are paired and enabled, both Macs receive the same SMS notification.

Important details:

- Removing a Mac on Android only stops future delivery to that Mac.
- It does not delete the `ntfy` topic from the server.
- If you want to fully rotate the topic, create a new QR code on that Mac.

## Release Artifacts

Official GitHub Releases usually include:

- `app-release.apk`: Android installer
- `woojusagwa-macos-arm64.dmg`: macOS installer

Starting with `v1.0.0`, the Android APK is published as a **release-signed APK** using one persistent keystore.  
That makes in-place updates possible across future official releases.

## Quick Start

### 1. Install the macOS app

1. Download `woojusagwa-macos-arm64.dmg` from GitHub Releases.
2. Open the DMG and drag `우주사과.app` into `Applications`.
3. Launch `/Applications/우주사과.app`.
4. Click the Woojusagwa menu bar icon.
5. Allow notification permission when macOS asks.

Recommended:

- In `System Settings > Notifications > 우주사과`, enable banners and Notification Center.
- Do not run the app directly from the DMG.

### 2. Install the Android app

1. Download and install `app-release.apk`.
2. Open Woojusagwa on Android.
3. Tap `Open Notification Access`.
4. Enable `Woojusagwa` in Android notification access settings.

Supported SMS notification sources:

- Samsung Messages
- Google Messages

### 3. Pair your first Mac

1. On the Mac menu bar app, click `Create New Pairing QR`.
2. On Android, tap `Pair with Mac (Scan QR)`.
3. Scan the QR code.
4. Confirm the new Mac appears in the `Paired Macs` list.

Repeat the same flow on every additional Mac.

### 4. Verify delivery

1. Receive a test SMS on the Galaxy phone.
2. Check that the Mac app state changes to the receiving state.
3. Check for a native macOS notification banner.
4. If it is an OTP-style message, check that the `Copy` action appears.

## Permission Guide

### Android

Woojusagwa does not read SMS databases directly.  
It reads **notifications** emitted by SMS apps.

Required permission:

- Notification access

Path:

- `Settings > Notifications > Notification access`

Enable `Woojusagwa` there.

### macOS

Woojusagwa shows incoming messages in the menu bar app and Notification Center.

Required permission:

- Notifications allowed

Path:

- `System Settings > Notifications > 우주사과`

Recommended options:

- Allow notifications
- Show in Notification Center
- Banner or Alert style

## Troubleshooting

### macOS notifications do not appear

Check in this order:

1. Make sure the app is launched from `/Applications`
2. Check whether the menu bar app shows `Notification permission needed`
3. Confirm notification permission in `System Settings > Notifications > 우주사과`
4. Make sure Focus mode is not suppressing banners
5. Use the built-in test notification from the menu bar app

### A Mac does not show up on Android

- Scan the QR code again.
- If the Mac was already paired, the Android app updates it by `device_id`.
- If needed, generate a fresh QR code on that Mac to rotate to a new topic.

### APK update installation fails

Android updates require these two values to stay the same:

- `applicationId`
- signing certificate

From `v1.0.0`, official APKs use the same persistent release keystore.  
If you are coming from an older debug APK or a locally built debug APK, Android may reject the update because the signatures do not match. In that case, uninstall once and reinstall from the `app-release.apk` line. Future official updates should then install normally.

## Storage and Privacy

- There is no custom backend that stores your messages.
- Android stores paired Mac records and topic metadata locally.
- macOS stores its own pairing state and recent status locally.
- Topic strings should be treated like secrets.

Woojusagwa is a small relay utility, not a cloud messaging platform.  
That keeps data flow and cleanup comparatively simple.

## Development Environment

### Android

- Android Studio
- JDK 17
- Android SDK 34

### macOS

- Xcode 15 or newer recommended
- Build verification targets Apple Silicon Macs

## Local Build

### Android

```bash
cd android
./gradlew --no-daemon testDebugUnitTest assembleRelease
```

### macOS Core tests

```bash
cd macos/WoojusagwaCore
swift test
```

### macOS app build

```bash
xcodebuild -project macos/Woojusagwa/Woojusagwa.xcodeproj \
  -scheme Woojusagwa \
  -configuration Release \
  -derivedDataPath macos/build \
  -destination 'platform=macOS,arch=arm64' \
  CODE_SIGNING_ALLOWED=NO
```

## Maintainer Release Notes

Android updateable releases require the same release keystore every time.

GitHub Actions expects these repository secrets:

- `ANDROID_SIGNING_KEYSTORE_HEX`
- `ANDROID_SIGNING_STORE_PASSWORD`
- `ANDROID_SIGNING_KEY_ALIAS`
- `ANDROID_SIGNING_KEY_PASSWORD`

Release tag rules:

- `dev-*`: prerelease
- `v*`: full release

## Repository Layout

```text
woojusagwa/
├─ android/      # Android app
├─ macos/        # macOS menu bar app
├─ contracts/    # QR payload and relay schemas
├─ docs/         # design and planning docs
└─ assets/       # logo and static assets
```

## License

[MIT License](./LICENSE)
