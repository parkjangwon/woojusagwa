# Plan: woojusagwa MVP Implementation

Galaxy SMS → Mac notification relay.

## Goals

- [ ] Android: NotificationListenerService implementation (filter SMS)
- [ ] Android: ntfy publish implementation (HTTP POST)
- [ ] macOS: ntfy subscribe implementation (SSE/WebSocket)
- [ ] macOS: Notification display implementation
- [ ] Shared: QR Pairing flow implementation

## Tasks

### Phase 1: Android Core
- [ ] `SmsNotificationListener`: Filter Samsung/Google Messages
- [ ] `NtfyPublisher`: Publish to ntfy.sh topic

### Phase 2: macOS Core
- [ ] `NtfySubscriber`: Subscribe to ntfy.sh topic
- [ ] `NotificationManager`: Display native macOS notifications

### Phase 3: Pairing
- [ ] macOS: Generate random topic and QR code
- [ ] Android: Scan QR and save configuration

## Technical Constraints

- Native Kotlin (Android) / Swift (macOS)
- No custom backend (use ntfy.sh)
- Zero data storage on relay server
