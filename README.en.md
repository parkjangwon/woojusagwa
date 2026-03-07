# woojusagwa (우주사과) 🍎🚀

<div align="center">
  <p>
    <a href="./README.md">한국어</a> | 
    <strong>English</strong>
  </p>
</div>

**A tiny native bridge that makes Galaxy SMS feel at home on your Mac.**

A minimalist open-source utility for people who love Galaxy phones and still live on a Mac all day. Woojusagwa does one job: forward SMS notifications to macOS without adding accounts, dashboards, or a custom backend.

## Why This Exists

- **Small by design**: no sync platform, no account system, no analytics.
- **Native by default**: Android captures notifications natively, macOS receives them natively.
- **Understandable by nerds**: the relay path is simple enough to inspect and reason about.
- **Privacy first**: the `ntfy` topic is treated like a secret and message content is not stored unnecessarily.

## Who It Is For

- Galaxy phone users who work on a Mac
- People who prefer tiny utilities over heavy "ecosystems"
- Builders who want to inspect the whole relay path
- Anyone who does not want SMS forwarding to depend on a private backend

---

## 🌟 Key Features

- **Real-time Forwarding**: Samsung Messages & Google Messages notification support.
- **ntfy-based**: Reliable push delivery via open-source relay.
- **QR Pairing**: Easy setup with QR code scanning.
- **Native Experience**: Kotlin (Android) and SwiftUI (macOS) implementation.
- **Privacy First**: No custom backend, no data storage.
- **Quick Copy on Mac**: See the latest message in the menu bar and copy it fast.

## 🛠 Architecture

1. **Android**: `NotificationListenerService` captures SMS notifications.
2. **Relay**: `ntfy.sh` (Open source push service) delivers the message.
3. **macOS**: Menu bar app subscribes to the topic and shows native notifications.

## 📁 Repository Structure

```text
woojusagwa/
 ├─ android/      # Android App (Kotlin)
 ├─ macos/        # macOS App (SwiftUI)
 ├─ contracts/    # Shared API Schema
 ├─ docs/         # Architecture & PDCA reports
 └─ README.md     # Main Guide (Korean)
```

## 🚀 Getting Started

Check out the [Main Guide (README.md)](./README.md) for detailed setup instructions in Korean.

## 📄 License

MIT License.

---
<p align="center">
  <b>parkjangwon (vim@kakao.com)</b>
</p>
