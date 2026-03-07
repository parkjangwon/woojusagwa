package org.parkjw.woojusagwa.settings

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

class SettingsRepository(
    private val prefs: SharedPreferences,
    private val nowProvider: () -> Long = { System.currentTimeMillis() },
) {

    constructor(context: Context) : this(
        context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    )

    fun getTopic(): String {
        return prefs.getString(KEY_TOPIC, "") ?: ""
    }

    fun setTopic(topic: String) {
        prefs.edit().putString(KEY_TOPIC, topic).apply()
    }

    fun getServer(): String {
        return prefs.getString(KEY_SERVER, DEFAULT_SERVER) ?: DEFAULT_SERVER
    }

    fun setServer(server: String) {
        prefs.edit().putString(KEY_SERVER, server).apply()
    }

    fun getPairedMacs(): List<PairedMac> {
        val stored = prefs.getString(KEY_PAIRED_MACS_JSON, null)
        if (stored != null) {
            return decodePairedMacs(stored)
        }

        return migrateLegacyPairingIfNeeded()
    }

    fun getEnabledPairedMacs(): List<PairedMac> {
        return getPairedMacs().filter { it.enabled }
    }

    fun upsertPairedMac(pairedMac: PairedMac) {
        val current = getPairedMacs().toMutableList()
        val existingIndex = current.indexOfFirst { it.deviceId == pairedMac.deviceId }

        if (existingIndex >= 0) {
            val existing = current[existingIndex]
            current[existingIndex] = pairedMac.copy(pairedAt = existing.pairedAt)
        } else {
            current.add(pairedMac.copy(pairedAt = pairedMac.pairedAt.takeIf { it > 0 } ?: nowProvider()))
        }

        savePairedMacs(current)
    }

    fun setPairedMacEnabled(deviceId: String, enabled: Boolean) {
        val updated = getPairedMacs().map { pairedMac ->
            if (pairedMac.deviceId == deviceId) {
                pairedMac.copy(enabled = enabled)
            } else {
                pairedMac
            }
        }

        savePairedMacs(updated)
    }

    fun removePairedMac(deviceId: String) {
        savePairedMacs(getPairedMacs().filterNot { it.deviceId == deviceId })
    }

    fun isConfigured(): Boolean {
        return getPairedMacs().isNotEmpty()
    }

    private fun migrateLegacyPairingIfNeeded(): List<PairedMac> {
        val topic = getTopic().trim()
        if (topic.isEmpty()) {
            return emptyList()
        }

        val migrated = listOf(
            PairedMac(
                deviceId = "legacy-${normalizeDeviceIdComponent(topic)}",
                deviceName = LEGACY_DEVICE_NAME,
                server = getServer().trim().ifEmpty { DEFAULT_SERVER },
                topic = topic,
                enabled = true,
                pairedAt = nowProvider(),
            )
        )

        savePairedMacs(migrated)
        return migrated
    }

    private fun savePairedMacs(pairedMacs: List<PairedMac>) {
        val json = JSONArray()
        pairedMacs.forEach { pairedMac ->
            json.put(
                JSONObject().apply {
                    put("device_id", pairedMac.deviceId)
                    put("device_name", pairedMac.deviceName)
                    put("server", pairedMac.server)
                    put("topic", pairedMac.topic)
                    put("enabled", pairedMac.enabled)
                    put("paired_at", pairedMac.pairedAt)
                }
            )
        }

        prefs.edit().putString(KEY_PAIRED_MACS_JSON, json.toString()).apply()
    }

    private fun decodePairedMacs(rawJson: String): List<PairedMac> {
        val jsonArray = JSONArray(rawJson)
        val pairedMacs = mutableListOf<PairedMac>()

        for (index in 0 until jsonArray.length()) {
            val item = jsonArray.optJSONObject(index) ?: continue
            val deviceId = item.optString("device_id").trim()
            val deviceName = item.optString("device_name").trim()
            val topic = item.optString("topic").trim()
            val server = item.optString("server", DEFAULT_SERVER).trim().ifEmpty { DEFAULT_SERVER }

            if (deviceId.isEmpty() || deviceName.isEmpty() || topic.isEmpty()) {
                continue
            }

            pairedMacs.add(
                PairedMac(
                    deviceId = deviceId,
                    deviceName = deviceName,
                    server = server,
                    topic = topic,
                    enabled = item.optBoolean("enabled", true),
                    pairedAt = item.optLong("paired_at", 0L),
                )
            )
        }

        return pairedMacs
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

    companion object {
        private const val PREF_NAME = "woojusagwa_settings"
        private const val KEY_TOPIC = "topic"
        private const val KEY_SERVER = "server"
        private const val KEY_PAIRED_MACS_JSON = "paired_macs_json"
        private const val DEFAULT_SERVER = "https://ntfy.sh"
        private const val LEGACY_DEVICE_NAME = "기존 Mac"
    }
}
