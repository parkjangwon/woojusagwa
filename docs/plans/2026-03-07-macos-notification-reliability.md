# macOS Notification Reliability Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make incoming relay messages show up more reliably in macOS Notification Center and expose notification permission/test controls inside the menu bar app.

**Architecture:** Shift local notification delivery from an immediate request to a short scheduled trigger so the system handles it through Notification Center more consistently. Pair that with app-side notification status, a manual permission refresh path, and a test notification button so users can verify whether the OS is allowing alerts.

**Tech Stack:** SwiftUI, UserNotifications, XCTest, Xcode

---

### Task 1: Make notification requests system-scheduled

**Files:**
- Modify: `macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/MessageNotificationTests.swift`
- Modify: `macos/WoojusagwaCore/Sources/WoojusagwaCore/MessageNotification.swift`

**Step 1: Write the failing test**

Change the notification request test to expect:
- a `UNTimeIntervalNotificationTrigger`
- `timeInterval == 1`
- `repeats == false`

**Step 2: Run test to verify it fails**

Run:

```bash
cd macos/WoojusagwaCore
swift test --filter MessageNotificationTests/testBuildsScheduledRequestWithIncomingMessageContent
```

Expected: FAIL because the current request uses `trigger: nil`.

**Step 3: Write minimal implementation**

- update `MessageNotificationRequestFactory.makeRequest` to attach a one-second `UNTimeIntervalNotificationTrigger`

**Step 4: Run test to verify it passes**

Run the same command and confirm it passes.

**Step 5: Commit**

```bash
git add macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/MessageNotificationTests.swift macos/WoojusagwaCore/Sources/WoojusagwaCore/MessageNotification.swift
git commit -m "fix: schedule macos notifications through notification center"
```

### Task 2: Add permission and test controls to the menu bar app

**Files:**
- Modify: `macos/Woojusagwa/Notifications/NotificationManager.swift`
- Modify: `macos/Woojusagwa/Relay/NtfySubscriber.swift`
- Modify: `macos/Woojusagwa/UI/MenuBarView.swift`

**Step 1: Write the failing test**

Use the missing UI hooks as the red state:

```bash
rg -n "sendTestNotification|notificationAuthorizationStatus|requestNotificationAuthorization" macos/Woojusagwa
```

Expected: no matches.

**Step 2: Run test to verify it fails**

Expected: FAIL because the menu bar app currently cannot show a test notification or expose current notification permission state.

**Step 3: Write minimal implementation**

- track notification authorization state in `NotificationManager`
- add a manual authorization refresh/request path
- add a test notification action
- pass those controls through `NtfySubscriber`
- surface the state and buttons in `MenuBarView`

**Step 4: Run test to verify it passes**

Run the same `rg` command and then build:

```bash
cd macos/WoojusagwaCore
swift test
xcodebuild -project macos/Woojusagwa/Woojusagwa.xcodeproj -scheme Woojusagwa -configuration Release -derivedDataPath macos/build -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO
```

Expected: PASS.

**Step 5: Commit**

```bash
git add macos/Woojusagwa/Notifications/NotificationManager.swift macos/Woojusagwa/Relay/NtfySubscriber.swift macos/Woojusagwa/UI/MenuBarView.swift
git commit -m "feat: add macos notification diagnostics and test controls"
```
