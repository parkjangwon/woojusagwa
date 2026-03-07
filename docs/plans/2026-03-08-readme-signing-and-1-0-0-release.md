# 1.0.0 README, Signing, and Release Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rewrite the Korean and English READMEs for the final 1.0.0 product state, add stable Android release signing for updateable APK releases, and publish the official `v1.0.0` release.

**Architecture:** Keep the product architecture unchanged. Improve the repository surface area by making documentation match the current multi-Mac and notification behavior, and improve Android distribution by switching GitHub Releases from ephemeral debug-signed APKs to a stable release-signed APK backed by one persistent keystore stored in GitHub Secrets.

**Tech Stack:** Markdown, GitHub Actions, Android Gradle, Java keystore tooling, Kotlin/Swift version metadata

---

### Task 1: Capture Current Release Inputs

**Files:**
- Create: `docs/plans/2026-03-08-readme-signing-and-1-0-0-release.md`
- Modify: none
- Test: command output only

**Step 1: Inspect current docs and release workflow**

Run:

```bash
sed -n '1,260p' README.md
sed -n '1,260p' README.en.md
sed -n '1,220p' .github/workflows/release.yml
sed -n '1,260p' android/app/build.gradle
```

Expected: current README and Android release workflow are visible, including `assembleDebug` and `app-debug.apk`.

**Step 2: Inspect current version references**

Run:

```bash
rg -n "0\\.0\\.10|versionCode|CFBundleShortVersionString|CFBundleVersion" -S
```

Expected: all known version references are listed before editing.

### Task 2: Rewrite README in Korean and English

**Files:**
- Modify: `README.md`
- Modify: `README.en.md`
- Test: manual review via `sed`

**Step 1: Replace the current README structure with product-accurate content**

Cover:
- philosophy and target users
- current feature set
- multi-Mac pairing model
- Android/macOS install guide
- permissions and notification guide
- OTP copy behavior
- release artifact types
- developer release note about signed APK updates

**Step 2: Review both files**

Run:

```bash
sed -n '1,260p' README.md
sed -n '1,260p' README.en.md
```

Expected: both guides are complete, consistent, and match the current product.

### Task 3: Add Stable Android Release Signing

**Files:**
- Modify: `android/app/build.gradle`
- Modify: `.github/workflows/release.yml`
- Modify: `.gitignore`
- Create: `android/keystore.properties.example`
- Test: `./gradlew --no-daemon assembleRelease`

**Step 1: Make signing configurable from environment variables**

Implement a minimal release signing path in Gradle using:
- `ANDROID_SIGNING_STORE_FILE`
- `ANDROID_SIGNING_STORE_PASSWORD`
- `ANDROID_SIGNING_KEY_ALIAS`
- `ANDROID_SIGNING_KEY_PASSWORD`

Behavior:
- if all values exist, sign the release APK
- if not, keep local release builds possible without forcing debug signing

**Step 2: Switch GitHub release builds from debug APK to release APK**

Update the workflow to:
- decode the base64 keystore from a GitHub secret
- export the signing env vars
- run `./gradlew --no-daemon testDebugUnitTest assembleRelease`
- upload `android/app/build/outputs/apk/release/app-release.apk`
- keep `dev-*` as prerelease and `v*` as full release

**Step 3: Add maintainer-facing signing template**

Create `android/keystore.properties.example` documenting the required values without committing secrets.

**Step 4: Verify locally**

Run:

```bash
cd android
./gradlew --no-daemon testDebugUnitTest assembleRelease
```

Expected: build succeeds. If signing env vars are absent, the build should still produce a release artifact path without requiring repo changes.

### Task 4: Create and Register the Release Keystore

**Files:**
- Create outside repo: local keystore backup path
- Modify remote repo secrets via GitHub CLI
- Test: `gh secret list`

**Step 1: Generate one persistent keystore**

Run `keytool -genkeypair` once and store it outside the repo with restricted permissions.

**Step 2: Register GitHub secrets**

Create:
- `ANDROID_SIGNING_KEYSTORE_BASE64`
- `ANDROID_SIGNING_STORE_PASSWORD`
- `ANDROID_SIGNING_KEY_ALIAS`
- `ANDROID_SIGNING_KEY_PASSWORD`

**Step 3: Confirm secrets exist**

Run:

```bash
gh secret list
```

Expected: the four Android signing secrets appear in the repository secret list.

### Task 5: Bump Versions to 1.0.0 and Validate

**Files:**
- Modify: `android/app/build.gradle`
- Modify: `macos/Woojusagwa/Resources/Info.plist`
- Modify: `android/app/src/test/kotlin/org/parkjw/woojusagwa/MainActivityStateTest.kt`
- Modify: `macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/AppTextTests.swift`
- Test: Android + macOS build/test commands

**Step 1: Update product versions**

Set:
- Android `versionName` to `1.0.0`
- Android `versionCode` to a higher stable value than previous releases
- macOS `CFBundleShortVersionString` to `1.0.0`
- macOS `CFBundleVersion` to the matching build number

**Step 2: Update affected tests**

Replace older `0.0.10` expectations with the new version metadata.

**Step 3: Run verification**

Run:

```bash
cd android && ./gradlew --no-daemon testDebugUnitTest assembleRelease
cd /Users/pjw/dev/project/woojusagwa/macos/WoojusagwaCore && swift test
cd /Users/pjw/dev/project/woojusagwa && xcodebuild -project macos/Woojusagwa/Woojusagwa.xcodeproj -scheme Woojusagwa -configuration Release -derivedDataPath macos/build -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO
```

Expected: all tests and release builds pass.

### Task 6: Publish the Official 1.0.0 Release

**Files:**
- Modify: git history via commit and tag
- Test: GitHub Actions run + GitHub Release page

**Step 1: Commit the work**

Run:

```bash
git add README.md README.en.md .github/workflows/release.yml .gitignore android/app/build.gradle android/keystore.properties.example macos/Woojusagwa/Resources/Info.plist android/app/src/test/kotlin/org/parkjw/woojusagwa/MainActivityStateTest.kt macos/WoojusagwaCore/Tests/WoojusagwaCoreTests/AppTextTests.swift docs/plans/2026-03-08-readme-signing-and-1-0-0-release.md
git commit -m "Prepare 1.0.0 release and Android signing"
```

**Step 2: Push and tag**

Run:

```bash
git push origin main
git tag v1.0.0
git push origin v1.0.0
```

**Step 3: Verify GitHub release output**

Run:

```bash
gh run watch --exit-status
gh release view v1.0.0 --json tagName,url,isPrerelease,assets,targetCommitish
```

Expected: `v1.0.0` is published as a full release with `app-release.apk` and the macOS DMG.
