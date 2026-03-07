package org.parkjw.woojusagwa.notification

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.parkjw.woojusagwa.relay.NtfyPublisher
import org.json.JSONObject

class SmsNotificationListener : NotificationListenerService() {

    private val TAG = "SmsNotificationListener"
    private lateinit var publisher: NtfyPublisher
    private val relayDecider = SmsRelayDecider()

    override fun onCreate() {
        super.onCreate()
        publisher = NtfyPublisher(applicationContext)
    }

    override fun onNotificationPosted(sbn: StatusBarNotification?) {
        sbn ?: return
        val packageName = sbn.packageName

        val notification = sbn.notification
        val extras = notification.extras
        val currentTime = System.currentTimeMillis()
        val title = extras.getString("android.title") ?: getString(org.parkjw.woojusagwa.R.string.notification_sender_unknown)
        val body = extras.getCharSequence("android.text")?.toString().orEmpty()

        if (!relayDecider.shouldRelay(
                sourceApp = packageName,
                title = title,
                body = body,
                receivedAtMillis = currentTime
            )
        ) {
            return
        }

        Log.d(TAG, "Forwarding SMS relay from $packageName")
        
        val payload = JSONObject().apply {
            put("version", 1)
            put("sourceApp", packageName)
            put("title", title)
            put("body", body.trim())
            put("receivedAt", currentTime)
            put("deviceName", android.os.Build.MODEL)
        }

        publisher.publish(payload.toString())
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        // No-op for now
    }
}
