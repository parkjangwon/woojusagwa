package org.parkjw.woojusagwa.settings

import android.content.Context
import android.content.SharedPreferences

class SettingsRepository(private val context: Context) {

    private val PREF_NAME = "woojusagwa_settings"
    private val KEY_TOPIC = "topic"
    private val KEY_SERVER = "server"
    private val DEFAULT_SERVER = "https://ntfy.sh"

    private val prefs: SharedPreferences by lazy {
        context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }

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

    fun isConfigured(): Boolean {
        return getTopic().isNotEmpty()
    }
}
