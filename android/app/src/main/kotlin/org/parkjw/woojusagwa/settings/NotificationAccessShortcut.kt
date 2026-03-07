package org.parkjw.woojusagwa.settings

import android.content.Intent
import android.provider.Settings

object NotificationAccessShortcut {
    fun action(): String {
        return Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS
    }

    fun createIntent(): Intent {
        return Intent(action())
    }
}
