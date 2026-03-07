# AGENT.md

This document defines the rules for AI agents and developers working on the woojusagwa repository.

---

# Project

Name: woojusagwa  
Korean: 우주사과

Goal:

Forward Galaxy SMS notifications to macOS.

The product must remain **small, native, and reliable**.

---

# Product Scope

Allowed:

- Galaxy SMS notification relay
- ntfy integration
- QR pairing
- macOS notification display
- quick copy of notification text

Not allowed:

- general notification relay platform
- chat platform
- backend service
- user accounts
- analytics systems
- Flutter migration
- feature creep

---

# Monorepo Structure

```
/
├─ android
├─ macos
├─ contracts
├─ docs
├─ README.md
└─ AGENT.md
```

Android and macOS apps remain **platform-native**.

Do not attempt to share runtime logic between Kotlin and Swift.

Shared behavior must live in:

```
contracts/
docs/
```

---

# Engineering Principles

1. Keep the product small.
2. Prefer boring code.
3. Avoid clever abstractions.
4. Optimize for maintainability.
5. Prefer explicit behavior.
6. Avoid hidden side effects.
7. Respect platform differences.

---

# Code Style

- descriptive names
- small functions
- minimal abstraction
- explicit flow
- avoid god classes
- avoid "manager/util/helper" dumping grounds

Comments should explain:

- platform caveats
- reasoning
- tradeoffs

---

# Android Rules

Language:

Kotlin

Package:

```
org.parkjw.woojusagwa
```

Core component:

```
NotificationListenerService
```

Supported SMS apps:

- Samsung Messages
- Google Messages

Strategy:

Use **allowlist** filtering.

Do NOT capture all notifications.

Handle:

- duplicate notification events
- notification updates
- permission state

---

# macOS Rules

Language:

Swift / SwiftUI

UX:

- lightweight
- menubar-first
- native macOS feel

Features:

- show last received message
- show connection state
- allow quick copy

---

# ntfy Rules

ntfy is the relay transport.

Requirements:

- default server: https://ntfy.sh
- allow custom server
- topic must be random
- treat topic as secret

Pairing payload should include:

- server
- topic
- version

---

# Pairing

Pairing must use QR code.

Flow:

1. macOS generates pairing payload
2. macOS shows QR
3. Android scans
4. Android saves config
5. Android sends test message
6. macOS confirms receive

---

# Contracts

All message formats must live in:

```
contracts/
```

When payload changes:

1. update schema
2. update android sender
3. update mac receiver
4. update docs

---

# Logging

Provide minimal diagnostics.

Android:

- permission state
- last forwarded
- last error

macOS:

- connection state
- last received
- last error

Do not log sensitive content by default.

---

# Maintenance Bias

Always choose:

- smaller solution
- clearer code
- easier debugging
- lower maintenance cost

Avoid:

- premature architecture
- complex frameworks
- hidden behavior

---

# Agent Behaviour

When implementing tasks:

1. explain plan
2. implement small scoped change
3. update docs/contracts if needed
4. list modified files
5. describe risks

Never expand scope silently.

Never introduce backend infrastructure.
