package org.parkjw.woojusagwa.settings

data class PairedMac(
    val deviceId: String,
    val deviceName: String,
    val server: String,
    val topic: String,
    val enabled: Boolean,
    val pairedAt: Long,
)
