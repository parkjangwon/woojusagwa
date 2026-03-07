# Architecture

woojusagwa uses a simple relay architecture.

Galaxy → ntfy → Mac

---

# Flow

1. SMS arrives on Galaxy phone
2. Android NotificationListenerService receives notification
3. Notification filtered for SMS apps
4. Payload created
5. HTTP publish to ntfy
6. Mac app subscribed to topic
7. macOS notification shown

---

# Key Design Goals

- minimal complexity
- no backend server
- native platforms
- easy debugging
- stable contracts

---

# Reliability Considerations

Android may send multiple notification updates.

Implementation should:

- deduplicate messages
- ignore irrelevant updates
- avoid duplicate push

---

# Security

- ntfy topic treated as secret
- do not log message content by default
- minimal history retention
