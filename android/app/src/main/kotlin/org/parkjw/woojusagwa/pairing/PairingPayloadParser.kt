package org.parkjw.woojusagwa.pairing

import org.json.JSONObject

data class PairingPayload(
    val version: Int,
    val server: String,
    val topic: String,
    val deviceId: String,
    val deviceName: String,
)

class PairingPayloadParser(
    private val defaultServer: String = "https://ntfy.sh",
    private val legacyDeviceName: String = "기존 Mac",
) {
    fun parse(rawPayload: String): PairingPayload? {
        return runCatching {
            val json = JSONObject(rawPayload)
            val version = json.optInt("version", -1)
            val topic = json.optString("topic").trim()
            val server = json.optString("server", defaultServer).trim().ifEmpty { defaultServer }

            if (topic.isEmpty()) {
                return null
            }

            when (version) {
                1 -> PairingPayload(
                    version = version,
                    server = server,
                    topic = topic,
                    deviceId = "legacy-${normalizeDeviceIdComponent(topic)}",
                    deviceName = legacyDeviceName,
                )

                2 -> {
                    val deviceId = json.optString("device_id")
                        .ifEmpty { json.optString("deviceId") }
                        .trim()
                    val deviceName = json.optString("device_name")
                        .ifEmpty { json.optString("deviceName") }
                        .trim()

                    if (deviceId.isEmpty() || deviceName.isEmpty()) {
                        return null
                    }

                    PairingPayload(
                        version = version,
                        server = server,
                        topic = topic,
                        deviceId = deviceId,
                        deviceName = deviceName,
                    )
                }

                else -> null
            }
        }.getOrNull()
    }

    private fun normalizeDeviceIdComponent(rawValue: String): String {
        val normalized = rawValue
            .trim()
            .lowercase()
            .replace(Regex("[^a-z0-9]+"), "_")
            .trim('_')

        return if (normalized.isEmpty()) {
            "mac"
        } else {
            normalized
        }
    }
}
