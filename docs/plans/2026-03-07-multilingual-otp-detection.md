# Multilingual OTP Detection Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Expand OTP detection so macOS notifications recognize Korean, English, Japanese, and Chinese verification messages and keep showing the `복사하기` action.

**Architecture:** Keep the change inside `WoojusagwaCore` so behavior stays testable with `swift test`. Add failing examples for Japanese and Chinese verification wording, then widen the keyword detector just enough to satisfy those cases without changing the existing numeric code rules.

**Tech Stack:** Swift, Swift Package Manager, XCTest, UserNotifications

---

### Task 1: Add failing multilingual OTP examples

**Files:**
- Modify: `macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/MessageNotificationTests.swift`
- Test: `macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/MessageNotificationTests.swift`

**Step 1: Write the failing test**

Add examples that assert a `복사하기` action is attached when:
- a Japanese message says `認証コードは123456です`
- a simplified Chinese message says `验证码是123456`
- a traditional Chinese message says `驗證碼為123456`

**Step 2: Run test to verify it fails**

Run:

```bash
cd macos/WoojusagwaCore
swift test --filter MessageNotificationTests
```

Expected: FAIL because the detector does not yet include those language keywords.

**Step 3: Write minimal implementation**

- extend `OneTimeCodeDetector.keywordPattern` with the new language-specific verification terms

**Step 4: Run test to verify it passes**

Run the same command and confirm the focused tests pass.

**Step 5: Commit**

```bash
git add macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/MessageNotificationTests.swift macos/WoojusagwaCore/Sources/WoojusagwaCore/MessageNotification.swift
git commit -m "feat: expand otp detection language coverage"
```

### Task 2: Verify the app still builds

**Files:**
- Check: `macos/WoojusagwaCore/Sources/WoojusagwaCore/MessageNotification.swift`
- Check: `macos/Woojusagwa/Notifications/NotificationManager.swift`

**Step 1: Write the failing test**

Use the focused test failure from Task 1 as the red state. No new app-side behavior should be added here.

**Step 2: Run test to verify it fails**

Expected: FAIL until the detector pattern is widened.

**Step 3: Write minimal implementation**

- do not touch notification delivery logic
- keep the app-side action wiring as-is

**Step 4: Run test to verify it passes**

Run:

```bash
cd macos/WoojusagwaCore
swift test
xcodebuild -project macos/Woojusagwa/Woojusagwa.xcodeproj -scheme Woojusagwa -configuration Release -derivedDataPath macos/build -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO
```

Expected: PASS.

**Step 5: Commit**

```bash
git add -A
git commit -m "chore: verify multilingual otp notification support"
```
