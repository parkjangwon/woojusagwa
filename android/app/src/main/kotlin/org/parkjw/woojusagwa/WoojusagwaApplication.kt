package org.parkjw.woojusagwa

import android.app.Application
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.os.LocaleListCompat
import org.parkjw.woojusagwa.settings.AppLanguageStore

class WoojusagwaApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        AppCompatDelegate.setDefaultNightMode(AppCompatDelegate.MODE_NIGHT_NO)
        val currentLanguage = AppLanguageStore(this).currentLanguage()
        AppCompatDelegate.setApplicationLocales(LocaleListCompat.forLanguageTags(currentLanguage.tag))
    }
}
