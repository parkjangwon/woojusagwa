package org.parkjw.woojusagwa

import android.content.Context
import android.content.res.Configuration
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.util.Locale

@RunWith(RobolectricTestRunner::class)
class MainActivityLocalizationTest {

    @Test
    fun `uses Korean strings by default`() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val configuration = Configuration(context.resources.configuration)
        configuration.setLocale(Locale.KOREAN)
        val localizedContext = context.createConfigurationContext(configuration)

        assertEquals("연결된 Mac", localizedContext.getString(R.string.section_paired_macs))
        assertEquals("버전 %1\$s (%2\$d)", localizedContext.getString(R.string.version_value))
    }

    @Test
    fun `uses English strings when locale is English`() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val configuration = Configuration(context.resources.configuration)
        configuration.setLocale(Locale.ENGLISH)
        val localizedContext = context.createConfigurationContext(configuration)

        assertEquals("Paired Macs", localizedContext.getString(R.string.section_paired_macs))
        assertEquals("Version %1\$s (%2\$d)", localizedContext.getString(R.string.version_value))
        assertEquals("Open notification access", localizedContext.getString(R.string.action_open_notification_access))
        assertEquals("Scan Woojusagwa Mac QR", localizedContext.getString(R.string.qr_prompt))
    }
}
