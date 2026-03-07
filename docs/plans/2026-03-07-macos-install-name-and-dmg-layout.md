# macOS Install Name And DMG Layout Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make the installed macOS app display as `우주사과` and package the DMG with an `Applications` shortcut for drag-and-drop installation.

**Architecture:** Keep the app target name and release mechanics simple. Update the macOS bundle display metadata and product name in the Xcode project, then switch DMG packaging to a deterministic staging directory that contains the built app and a symlink to `/Applications`.

**Tech Stack:** SwiftUI, Xcode project settings, GitHub Actions, shell packaging commands

---

### Task 1: Verify the current mismatch

**Files:**
- Check: `macos/Woojusagwa/Resources/Info.plist`
- Check: `.github/workflows/release.yml`

**Step 1: Write the failing test**

Run:

```bash
plutil -extract CFBundleDisplayName raw -o - macos/Woojusagwa/Resources/Info.plist
plutil -extract CFBundleName raw -o - macos/Woojusagwa/Resources/Info.plist
rg -n "Applications|ln -s /Applications|srcfolder .*\\.app" .github/workflows/release.yml
```

**Step 2: Run test to verify it fails**

Expected:
- display name is not `우주사과`
- DMG workflow has no `Applications` shortcut staging

**Step 3: Write minimal implementation**

- Update bundle display metadata
- Update Xcode product name
- Update release workflow DMG packaging

**Step 4: Run test to verify it passes**

Run the same commands and confirm the new values/layout are present.

**Step 5: Commit**

```bash
git add macos/Woojusagwa/Resources/Info.plist macos/Woojusagwa/Woojusagwa.xcodeproj/project.pbxproj .github/workflows/release.yml
git commit -m "feat: polish macos install name and dmg layout"
```

### Task 2: Verify the release artifact shape

**Files:**
- Check: `macos/build/Build/Products/Release/우주사과.app`
- Check: `macos/build/artifacts/woojusagwa-macos.dmg`

**Step 1: Write the failing test**

Run the existing release build once before changes and confirm the output app name/layout does not match.

**Step 2: Run test to verify it fails**

Expected:
- built app bundle name is not yet `우주사과.app`
- DMG staging does not include the `Applications` shortcut

**Step 3: Write minimal implementation**

- rebuild the macOS release app
- create a staged DMG source folder with the renamed app and `/Applications` symlink

**Step 4: Run test to verify it passes**

Run:

```bash
xcodebuild -project macos/Woojusagwa/Woojusagwa.xcodeproj -scheme Woojusagwa -configuration Release -derivedDataPath macos/build -destination 'platform=macOS,arch=arm64' CODE_SIGNING_ALLOWED=NO
test -d macos/build/Build/Products/Release/우주사과.app
test -L macos/build/dmg/Applications
```

Expected: PASS.

**Step 5: Commit**

```bash
git add -A
git commit -m "chore: verify macos release packaging"
```
