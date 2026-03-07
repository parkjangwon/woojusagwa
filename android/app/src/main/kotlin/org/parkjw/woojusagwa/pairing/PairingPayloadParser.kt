package org.parkjw.woojusagwa.pairing

import org.json.JSONObject

data class PairingPayload(
    val version: Int,
    val server: String,
    val topic: String,
)

class PairingPayloadParser(
    private val supportedVersion: Int = 1,
    private val defaultServer: String = "https://ntfy.sh",
) {
    fun parse(rawPayload: String): PairingPayload? {
        return runCatching {
            val json = JSONObject(rawPayload)
            val version = json.optInt("version", -1)
            val topic = json.optString("topic").trim()
            val server = json.optString("server", defaultServer).trim().ifEmpty { defaultServer }

            if (version != supportedVersion || topic.isEmpty()) {
                return null
            }

            PairingPayload(
                version = version,
                server = server,
                topic = topic,
            )
        }.getOrNull()
    }
}
