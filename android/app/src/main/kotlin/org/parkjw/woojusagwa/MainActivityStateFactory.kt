package org.parkjw.woojusagwa

import org.parkjw.woojusagwa.settings.PairedMac

data class PairedMacRowState(
    val deviceId: String,
    val deviceName: String,
    val topic: String,
    val server: String,
    val enabled: Boolean,
)

data class MainActivityState(
    val versionName: String,
    val versionCode: Int,
    val pairedMacCount: Int,
    val enabledPairedMacCount: Int,
    val pairedMacRows: List<PairedMacRowState>,
    val hasPairedMacs: Boolean,
)

class MainActivityStateFactory {
    fun create(
        versionName: String,
        versionCode: Int,
        pairedMacs: List<PairedMac>,
    ): MainActivityState {
        val rows = pairedMacs
            .sortedBy { it.pairedAt }
            .map { pairedMac ->
                PairedMacRowState(
                    deviceId = pairedMac.deviceId,
                    deviceName = pairedMac.deviceName,
                    topic = pairedMac.topic,
                    server = pairedMac.server,
                    enabled = pairedMac.enabled,
                )
            }

        return MainActivityState(
            versionName = versionName,
            versionCode = versionCode,
            pairedMacCount = rows.size,
            enabledPairedMacCount = rows.count { it.enabled },
            pairedMacRows = rows,
            hasPairedMacs = rows.isNotEmpty(),
        )
    }
}
