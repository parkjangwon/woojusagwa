# macOS Local Notifications Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make incoming relay messages appear as native macOS notifications while keeping the existing menu bar status and last-message view intact.

**Architecture:** Introduce a small notification request/presentation policy in `WoojusagwaCore` so it can be tested with `swift test`, then make the macOS app's `NotificationManager` adopt `UNUserNotificationCenterDelegate` and use that policy to force banner delivery while the menu bar app is active.

**Tech Stack:** SwiftUI, UserNotifications, Swift Package Manager, Xcode

---

### Task 1: Add a testable notification presentation policy

**Files:**
- Create: `macos/WoojusagwaCore/Sources/WoojusagwaCore/MessageNotification.swift`
- Create: `macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/MessageNotificationTests.swift`

**Step 1: Write the failing test**

Add tests that assert:
- a notification request preserves the incoming title and body
- the request is delivered immediately with no trigger
- foreground presentation options include `banner`, `list`, and `sound`

**Step 2: Run test to verify it fails**

Run:

```bash
cd macos/WoojusagwaCore
swift test --filter MessageNotificationTests
```

Expected: FAIL because `MessageNotificationRequestFactory` does not exist yet.

**Step 3: Write minimal implementation**

- add a tiny request factory and foreground presentation policy

**Step 4: Run test to verify it passes**

Run the same command and confirm the tests pass.

**Step 5: Commit**

```bash
git add macos/WoojusagwaCore/Sources/WoojusagwaCore/MessageNotification.swift macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/MessageNotificationTests.swift
git commit -m "feat: add macos notification request policy"
```

### Task 2: Wire the policy into the macOS app

**Files:**
- Modify: `macos/Woojusagwa/Notifications/NotificationManager.swift`
- Modify: `macos/Woojusagwa/Relay/NtfySubscriber.swift`

**Step 1: Write the failing test**

Run:

```bash
rg -n "UNUserNotificationCenterDelegate|willPresent|foregroundPresentationOptions" macos/Woojusagwa/Notifications/NotificationManager.swift
```

**Step 2: Run test to verify it fails**

Expected: FAIL because the current manager does not set a notification center delegate or define foreground presentation behavior.

**Step 3: Write minimal implementation**

- make `NotificationManager` the `UNUserNotificationCenter` delegate
- set the center delegate during initialization
- keep permission requests
- deliver local notifications using the new request factory

**Step 4: Run test to verify it passes**

Run the same `rg` command and confirm the delegate wiring is present, then build:

```bash
xcodebuild -project macos/Woojusagwa/Woojusagwa.xcodeproj -scheme Woojusagwa -configuration Release -derivedDataPath macos/build -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO
```

Expected: PASS.

**Step 5: Commit**

```bash
git add macos/Woojusagwa/Notifications/NotificationManager.swift macos/Woojusagwa/Relay/NtfySubscriber.swift
git commit -m "feat: show incoming relay messages as macos notifications"
```
