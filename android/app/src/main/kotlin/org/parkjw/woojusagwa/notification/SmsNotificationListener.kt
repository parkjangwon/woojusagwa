package org.parkjw.woojusagwa.notification

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.parkjw.woojusagwa.relay.NtfyPublisher
import org.parkjw.woojusagwa.settings.SettingsRepository
import org.json.JSONObject

class SmsNotificationListener : NotificationListenerService() {

    private val TAG = "SmsNotificationListener"
    private val SMS_APPS = setOf(
        "com.samsung.android.messaging",
        "com.google.android.apps.messaging"
    )

    private lateinit var publisher: NtfyPublisher
    private lateinit var settings: SettingsRepository
    private var lastMessageBody: String? = null
    private var lastMessageTime: Long = 0

    override fun onCreate() {
        super.onCreate()
        publisher = NtfyPublisher(applicationContext)
        settings = SettingsRepository(applicationContext)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn ?: return
        val packageName = sbn.packageName
        
        if (!SMS_APPS.contains(packageName)) return

        val notification = sbn.notification
        val extras = notification.extras
        val title = extras.getString("android.title") ?: "Unknown"
        val body = extras.getCharSequence("android.text")?.toString() ?: ""

        if (body.isEmpty()) return
        
        // Simple deduplication: skip if body is same as last one and within 3 seconds
        val currentTime = System.currentTimeMillis()
        if (body == lastMessageBody && (currentTime - lastMessageTime) < 3000) {
            return
        }
        
        lastMessageBody = body
        lastMessageTime = currentTime

        Log.d(TAG, "Forwarding SMS from $packageName: $title")
        
        val payload = JSONObject().apply {
            put("version", 1)
            put("sourceApp", packageName)
            put("title", title)
            put("body", body)
            put("receivedAt", System.currentTimeMillis())
            put("deviceName", android.os.Build.MODEL)
        }

        publisher.publish(payload.toString())
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // No-op for now
    }
}
