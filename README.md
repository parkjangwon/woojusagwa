# woojusagwa (우주사과) 🍎🚀

<div align="center">
  <p>
    <strong>English</strong> | 
    <a href="./README.ko.md">한국어</a>
  </p>
</div>

**Galaxy SMS → Mac notification relay.**

A minimalist native app to forward Galaxy smartphone text notifications to macOS using `ntfy`.

---

## 🌟 Key Features

- **Real-time Forwarding**: Samsung Messages & Google Messages notification support.
- **ntfy-based**: Reliable push delivery via open-source relay.
- **QR Pairing**: Easy setup with QR code scanning.
- **Native Experience**: Kotlin (Android) and SwiftUI (macOS) implementation.
- **Privacy First**: No custom backend, no data storage.

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
 └─ README.md     # Main Guide
```

## 🚀 Getting Started

Check out the [Korean Guide (README.ko.md)](./README.ko.md) for detailed setup instructions.

## 📄 License

MIT License.

---
<p align="center">
  <b>parkjangwon (vim@kakao.com)</b>
</p>
