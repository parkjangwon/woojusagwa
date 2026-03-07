package org.parkjw.woojusagwa.notification

class SmsRelayDecider(
    private val dedupeWindowMillis: Long = 3_000L,
    private val allowedPackages: Set<String> = setOf(
        "com.samsung.android.messaging",
        "com.google.android.apps.messaging",
    ),
) {
    private var lastSignature: String? = null
    private var lastRelayAtMillis: Long = Long.MIN_VALUE

    fun shouldRelay(
        sourceApp: String,
        title: String,
        body: String,
        receivedAtMillis: Long,
    ): Boolean {
        val normalizedBody = body.trim()
        if (sourceApp !in allowedPackages || normalizedBody.isEmpty()) {
            return false
        }

        val signature = listOf(sourceApp, title.trim(), normalizedBody).joinToString(separator = "\u0000")
        val isDuplicate = signature == lastSignature && receivedAtMillis - lastRelayAtMillis < dedupeWindowMillis

        if (isDuplicate) {
            return false
        }

        lastSignature = signature
        lastRelayAtMillis = receivedAtMillis
        return true
    }
}
