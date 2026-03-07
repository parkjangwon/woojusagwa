package org.parkjw.woojusagwa.settings

import android.provider.Settings
import org.junit.Assert.assertEquals
import org.junit.Test

class NotificationAccessShortcutTest {

    @Test
    fun `returns notification listener settings action`() {
        val action = NotificationAccessShortcut.action()

        assertEquals(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS, action)
    }
}
