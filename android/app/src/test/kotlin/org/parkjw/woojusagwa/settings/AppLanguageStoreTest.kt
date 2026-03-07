package org.parkjw.woojusagwa.settings

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AppLanguageStoreTest {

    private lateinit var context: Context

    @Before
    fun setUp() {
        context = ApplicationProvider.getApplicationContext()
        context.getSharedPreferences("woojusagwa_language_test", Context.MODE_PRIVATE).edit().clear().commit()
    }

    @Test
    fun `defaults to Korean`() {
        val prefs = context.getSharedPreferences("woojusagwa_language_test", Context.MODE_PRIVATE)
        val store = AppLanguageStore(prefs)

        assertEquals(AppLanguage.KOREAN, store.currentLanguage())
    }

    @Test
    fun `persists selected English language`() {
        val prefs = context.getSharedPreferences("woojusagwa_language_test", Context.MODE_PRIVATE)
        val store = AppLanguageStore(prefs)

        store.setLanguage(AppLanguage.ENGLISH)

        assertEquals(AppLanguage.ENGLISH, store.currentLanguage())
    }

    @Test
    fun `falls back to Korean for unsupported stored language`() {
        val prefs = context.getSharedPreferences("woojusagwa_language_test", Context.MODE_PRIVATE)
        prefs.edit().putString("app_language", "fr").commit()
        val store = AppLanguageStore(prefs)

        assertEquals(AppLanguage.KOREAN, store.currentLanguage())
    }
}
