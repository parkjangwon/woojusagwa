# Design: woojusagwa MVP Implementation

Galaxy SMS → Mac notification relay.

## Components

### 1. Android: `SmsNotificationListener`
- **Class**: `org.parkjw.woojusagwa.notification.SmsNotificationListener` (inherits `NotificationListenerService`)
- **Action**: Filters notifications from `com.samsung.android.messaging` and `com.google.android.apps.messaging`.
- **Payload**: Formats notification content into `relay-message.schema.json`.

### 2. Android: `NtfyPublisher`
- **Class**: `org.parkjw.woojusagwa.relay.NtfyPublisher`
- **Action**: Sends HTTP POST to `https://ntfy.sh/{topic}` with the JSON payload.

### 3. macOS: `NtfySubscriber`
- **Class**: `NtfySubscriber` (Swift)
- **Action**: Uses `EventSource` (SSE) or WebSocket to subscribe to `https://ntfy.sh/{topic}/json`.

### 4. macOS: `NotificationManager`
- **Class**: `NotificationManager` (Swift)
- **Action**: Uses `UNUserNotificationCenter` to display the relay message.

## Data Flow

1. **Android**: `onNotificationPosted` → Filter → `NtfyPublisher.publish(payload)`
2. **Network**: `POST https://ntfy.sh/{topic}`
3. **Network**: `SSE https://ntfy.sh/{topic}/json`
4. **macOS**: `onMessageReceived` → `NotificationManager.show(payload)`

## Implementation Strategy

1. **Skeleton**: Create the basic project structure on both platforms.
2. **Ntfy Publish/Subscribe**: Verify connectivity using simple text messages.
3. **Payload Mapping**: Implement the JSON schema mapping.
4. **Listener/UI**: Connect the Android service and macOS notifications.
