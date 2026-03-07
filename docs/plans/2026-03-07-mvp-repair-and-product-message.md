# Woojusagwa MVP Repair And Product Message Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make Woojusagwa buildable again, harden the MVP behavior, and clarify the product philosophy for Galaxy-and-Mac users across the app and docs.

**Architecture:** Keep the product small and native. Extract the Android behaviors that can be tested on the JVM into small pure helpers, repair the broken Gradle wrapper/build path, and rebuild the macOS app around a minimal Xcode project with small testable Swift types for pairing and relay parsing. Refresh user-facing copy only where it reinforces the existing product scope.

**Tech Stack:** Kotlin, Android SDK, JUnit4, Swift 6, SwiftUI, XCTest, Gradle, Xcode

---

### Task 1: Restore Android test and build baseline

**Files:**
- Modify: `android/build.gradle`
- Modify: `android/app/build.gradle`
- Modify: `android/gradlew`
- Create/Restore: `android/gradle/wrapper/gradle-wrapper.jar`

**Step 1: Write the failing test**

Run:

```bash
cd android && ./gradlew testDebugUnitTest
```

Expected: FAIL because the wrapper is broken or the test task cannot start.

**Step 2: Run test to verify it fails**

Run:

```bash
cd android && ./gradlew testDebugUnitTest
```

Expected: shell or Gradle startup failure from the wrapper path.

**Step 3: Write minimal implementation**

- Regenerate the wrapper with local Gradle.
- Restore a standard `gradlew` launcher.
- Add the Android unit test dependencies needed for JVM tests.

**Step 4: Run test to verify it passes**

Run:

```bash
cd android && ./gradlew testDebugUnitTest
```

Expected: Gradle starts successfully and unit tests execute.

**Step 5: Commit**

```bash
git add android/build.gradle android/app/build.gradle android/gradlew android/gradle/wrapper/gradle-wrapper.jar
git commit -m "build: restore android wrapper and test baseline"
```

### Task 2: Add failing Android tests for pairing and notification filtering

**Files:**
- Create: `android/app/src/test/kotlin/org/parkjw/woojusagwa/pairing/PairingPayloadParserTest.kt`
- Create: `android/app/src/test/kotlin/org/parkjw/woojusagwa/notification/SmsRelayDeciderTest.kt`
- Create: `android/app/src/main/kotlin/org/parkjw/woojusagwa/pairing/PairingPayloadParser.kt`
- Create: `android/app/src/main/kotlin/org/parkjw/woojusagwa/notification/SmsRelayDecider.kt`

**Step 1: Write the failing test**

Add tests that verify:
- valid QR payloads parse `version`, `server`, and `topic`
- invalid payloads are rejected
- only allowlisted SMS apps relay
- empty bodies do not relay
- duplicate messages in the suppression window do not relay

**Step 2: Run test to verify it fails**

Run:

```bash
cd android && ./gradlew testDebugUnitTest --tests '*PairingPayloadParserTest' --tests '*SmsRelayDeciderTest'
```

Expected: FAIL because helper types do not exist yet.

**Step 3: Write minimal implementation**

- Add a small pairing parser that returns a typed result.
- Add a pure relay decider that owns allowlist and dedupe behavior.

**Step 4: Run test to verify it passes**

Run:

```bash
cd android && ./gradlew testDebugUnitTest --tests '*PairingPayloadParserTest' --tests '*SmsRelayDeciderTest'
```

Expected: PASS.

**Step 5: Commit**

```bash
git add android/app/src/test/kotlin android/app/src/main/kotlin/org/parkjw/woojusagwa/pairing android/app/src/main/kotlin/org/parkjw/woojusagwa/notification
git commit -m "test: cover pairing parsing and sms relay decisions"
```

### Task 3: Wire Android UI and service to the tested helpers

**Files:**
- Modify: `android/app/src/main/kotlin/org/parkjw/woojusagwa/MainActivity.kt`
- Modify: `android/app/src/main/kotlin/org/parkjw/woojusagwa/notification/SmsNotificationListener.kt`
- Modify: `android/app/src/main/res/layout/activity_main.xml`
- Modify: `android/app/src/main/res/values/strings.xml`

**Step 1: Write the failing test**

Extend the existing helper tests with:
- custom server fallback behavior
- duplicate suppression using title + body + package instead of body alone

**Step 2: Run test to verify it fails**

Run:

```bash
cd android && ./gradlew testDebugUnitTest --tests '*PairingPayloadParserTest' --tests '*SmsRelayDeciderTest'
```

Expected: FAIL on the new assertions.

**Step 3: Write minimal implementation**

- Update the helpers and call sites.
- Make the Android copy clearer about pairing, privacy, and permission state.

**Step 4: Run test to verify it passes**

Run:

```bash
cd android && ./gradlew testDebugUnitTest
```

Expected: PASS.

**Step 5: Commit**

```bash
git add android/app/src/main/kotlin/org/parkjw/woojusagwa/MainActivity.kt android/app/src/main/kotlin/org/parkjw/woojusagwa/notification/SmsNotificationListener.kt android/app/src/main/res/layout/activity_main.xml android/app/src/main/res/values/strings.xml
git commit -m "feat: harden android pairing and relay flow"
```

### Task 4: Create failing Swift tests for pairing and relay decoding

**Files:**
- Create: `macos/WoojusagwaCore/Package.swift`
- Create: `macos/WoojusagwaCore/Sources/WoojusagwaCore/PairingPayload.swift`
- Create: `macos/WoojusagwaCore/Sources/WoojusagwaCore/RelayEnvelope.swift`
- Create: `macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/PairingPayloadTests.swift`
- Create: `macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/RelayEnvelopeTests.swift`

**Step 1: Write the failing test**

Add tests that verify:
- pairing payload JSON is encoded correctly
- relay envelope lines decode into title/body pairs
- malformed lines are rejected safely

**Step 2: Run test to verify it fails**

Run:

```bash
cd macos/WoojusagwaCore && swift test
```

Expected: FAIL because the core types do not exist yet.

**Step 3: Write minimal implementation**

- Add tiny `Codable` models for pairing and relay parsing.

**Step 4: Run test to verify it passes**

Run:

```bash
cd macos/WoojusagwaCore && swift test
```

Expected: PASS.

**Step 5: Commit**

```bash
git add macos/WoojusagwaCore
git commit -m "test: add swift core models for pairing and relay decoding"
```

### Task 5: Rebuild the macOS app around the tested core and a real Xcode project

**Files:**
- Create: `macos/Woojusagwa/Woojusagwa.xcodeproj/project.pbxproj`
- Modify: `macos/Woojusagwa/App/WoojusagwaApp.swift`
- Modify: `macos/Woojusagwa/UI/MenuBarView.swift`
- Modify: `macos/Woojusagwa/Relay/NtfySubscriber.swift`
- Modify: `macos/Woojusagwa/Notifications/NotificationManager.swift`
- Create: `macos/Woojusagwa/Resources/Info.plist`
- Create: `macos/Woojusagwa/Resources/Assets.xcassets/...`

**Step 1: Write the failing test**

Run:

```bash
xcodebuild -project macos/Woojusagwa/Woojusagwa.xcodeproj -scheme Woojusagwa -configuration Debug -destination 'platform=macOS'
```

Expected: FAIL before the project exists or before the app builds cleanly.

**Step 2: Run test to verify it fails**

Run the same command and confirm a project/build failure.

**Step 3: Write minimal implementation**

- Add a small Xcode project.
- Use the tested `PairingPayload` and `RelayEnvelope` models.
- Fix the invalid Swift syntax and macOS image APIs.
- Improve the menu bar copy so the product philosophy is obvious.

**Step 4: Run test to verify it passes**

Run:

```bash
xcodebuild -project macos/Woojusagwa/Woojusagwa.xcodeproj -scheme Woojusagwa -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
```

Expected: BUILD SUCCEEDED.

**Step 5: Commit**

```bash
git add macos/Woojusagwa
git commit -m "feat: restore macos app project and menubar experience"
```

### Task 6: Clarify product philosophy in docs and release workflow

**Files:**
- Modify: `README.md`
- Modify: `README.en.md`
- Modify: `.github/workflows/release.yml`

**Step 1: Write the failing test**

Run:

```bash
rg -n "작고|native|Galaxy|Mac|nerd|privacy|ntfy" README.md README.en.md .github/workflows/release.yml
```

Expected: copy does not yet fully reflect the refined philosophy or the updated build path.

**Step 2: Run test to verify it fails**

Run the same command and confirm the missing or outdated wording/build references.

**Step 3: Write minimal implementation**

- Rework the README positioning and setup language.
- Align release workflow paths with the restored project/build outputs.

**Step 4: Run test to verify it passes**

Run:

```bash
rg -n "갤럭시|Galaxy|Mac|native|privacy|ntfy" README.md README.en.md .github/workflows/release.yml
```

Expected: updated product copy and corrected build references are present.

**Step 5: Commit**

```bash
git add README.md README.en.md .github/workflows/release.yml
git commit -m "docs: sharpen product story and release workflow"
```

### Task 7: Final verification

**Files:**
- Modify if needed after verification fixes.

**Step 1: Write the failing test**

Run the full verification set before final cleanups:

```bash
cd android && ./gradlew testDebugUnitTest assembleDebug
cd ../macos/WoojusagwaCore && swift test
xcodebuild -project /Users/pjw/dev/project/woojusagwa/macos/Woojusagwa/Woojusagwa.xcodeproj -scheme Woojusagwa -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO
```

Expected: at least one command fails before the full set of repairs is complete.

**Step 2: Run test to verify it fails**

Run the commands and record remaining failures.

**Step 3: Write minimal implementation**

- Fix only the issues revealed by the verification step.

**Step 4: Run test to verify it passes**

Re-run the same commands until all pass.

**Step 5: Commit**

```bash
git add -A
git commit -m "chore: finalize mvp repair verification"
```
