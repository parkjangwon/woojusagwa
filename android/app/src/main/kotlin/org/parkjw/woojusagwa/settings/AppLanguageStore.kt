package org.parkjw.woojusagwa.settings

import android.content.Context
import android.content.SharedPreferences

enum class AppLanguage(val tag: String) {
    KOREAN("ko"),
    ENGLISH("en");

    companion object {
        fun fromTag(rawValue: String?): AppLanguage {
            val normalized = rawValue
                ?.trim()
                ?.lowercase()
                .orEmpty()

            return if (normalized.startsWith(ENGLISH.tag)) {
                ENGLISH
            } else {
                KOREAN
            }
        }
    }
}

class AppLanguageStore(
    private val prefs: SharedPreferences,
) {

    constructor(context: Context) : this(
        context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    )

    fun currentLanguage(): AppLanguage {
        return AppLanguage.fromTag(prefs.getString(KEY_APP_LANGUAGE, AppLanguage.KOREAN.tag))
    }

    fun setLanguage(language: AppLanguage) {
        prefs.edit().putString(KEY_APP_LANGUAGE, language.tag).apply()
    }

    companion object {
        private const val PREF_NAME = "woojusagwa_settings"
        private const val KEY_APP_LANGUAGE = "app_language"
    }
}
