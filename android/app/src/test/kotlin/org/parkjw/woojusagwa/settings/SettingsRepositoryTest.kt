package org.parkjw.woojusagwa.settings

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class SettingsRepositoryTest {

    private lateinit var context: Context

    @Before
    fun setUp() {
        context = ApplicationProvider.getApplicationContext()
        context.getSharedPreferences("woojusagwa_settings_test", Context.MODE_PRIVATE).edit().clear().commit()
    }

    @Test
    fun `saves and loads multiple paired macs`() {
        val prefs = context.getSharedPreferences("woojusagwa_settings_test", Context.MODE_PRIVATE)
        val repository = SettingsRepository(prefs, nowProvider = { 1_000L })

        repository.upsertPairedMac(
            PairedMac(
                deviceId = "mac-home",
                deviceName = "개인 MacBook Pro",
                server = "https://ntfy.sh",
                topic = "ws_home",
                enabled = true,
                pairedAt = 1_000L
            )
        )
        repository.upsertPairedMac(
            PairedMac(
                deviceId = "mac-work",
                deviceName = "회사 MacBook Air",
                server = "https://relay.example",
                topic = "ws_work",
                enabled = true,
                pairedAt = 2_000L
            )
        )

        val pairedMacs = repository.getPairedMacs()

        assertEquals(2, pairedMacs.size)
        assertEquals("개인 MacBook Pro", pairedMacs[0].deviceName)
        assertEquals("회사 MacBook Air", pairedMacs[1].deviceName)
    }

    @Test
    fun `upserts same device id instead of duplicating`() {
        val prefs = context.getSharedPreferences("woojusagwa_settings_test", Context.MODE_PRIVATE)
        val repository = SettingsRepository(prefs, nowProvider = { 1_000L })

        repository.upsertPairedMac(
            PairedMac(
                deviceId = "mac-home",
                deviceName = "개인 MacBook Pro",
                server = "https://ntfy.sh",
                topic = "ws_home",
                enabled = true,
                pairedAt = 1_000L
            )
        )
        repository.upsertPairedMac(
            PairedMac(
                deviceId = "mac-home",
                deviceName = "개인 MacBook Pro 16",
                server = "https://ntfy.sh",
                topic = "ws_home_new",
                enabled = true,
                pairedAt = 9_000L
            )
        )

        val pairedMacs = repository.getPairedMacs()

        assertEquals(1, pairedMacs.size)
        assertEquals("개인 MacBook Pro 16", pairedMacs[0].deviceName)
        assertEquals("ws_home_new", pairedMacs[0].topic)
        assertEquals(1_000L, pairedMacs[0].pairedAt)
    }

    @Test
    fun `toggles one paired mac enabled state`() {
        val prefs = context.getSharedPreferences("woojusagwa_settings_test", Context.MODE_PRIVATE)
        val repository = SettingsRepository(prefs, nowProvider = { 1_000L })

        repository.upsertPairedMac(
            PairedMac(
                deviceId = "mac-home",
                deviceName = "개인 MacBook Pro",
                server = "https://ntfy.sh",
                topic = "ws_home",
                enabled = true,
                pairedAt = 1_000L
            )
        )

        repository.setPairedMacEnabled("mac-home", false)

        assertFalse(repository.getPairedMacs().first().enabled)
        assertTrue(repository.getEnabledPairedMacs().isEmpty())
    }

    @Test
    fun `removes one paired mac`() {
        val prefs = context.getSharedPreferences("woojusagwa_settings_test", Context.MODE_PRIVATE)
        val repository = SettingsRepository(prefs, nowProvider = { 1_000L })

        repository.upsertPairedMac(
            PairedMac(
                deviceId = "mac-home",
                deviceName = "개인 MacBook Pro",
                server = "https://ntfy.sh",
                topic = "ws_home",
                enabled = true,
                pairedAt = 1_000L
            )
        )
        repository.upsertPairedMac(
            PairedMac(
                deviceId = "mac-work",
                deviceName = "회사 MacBook Air",
                server = "https://ntfy.sh",
                topic = "ws_work",
                enabled = true,
                pairedAt = 2_000L
            )
        )

        repository.removePairedMac("mac-home")

        val pairedMacs = repository.getPairedMacs()
        assertEquals(1, pairedMacs.size)
        assertEquals("mac-work", pairedMacs.first().deviceId)
    }

    @Test
    fun `migrates legacy single topic settings into one paired mac`() {
        val prefs = context.getSharedPreferences("woojusagwa_settings_test", Context.MODE_PRIVATE)
        prefs.edit()
            .putString("topic", "ws_legacy")
            .putString("server", "https://ntfy.sh")
            .commit()
        val repository = SettingsRepository(prefs, nowProvider = { 4_242L })

        val pairedMacs = repository.getPairedMacs()

        assertEquals(1, pairedMacs.size)
        assertEquals("legacy-ws_legacy", pairedMacs.first().deviceId)
        assertEquals("기존 Mac", pairedMacs.first().deviceName)
        assertEquals(4_242L, pairedMacs.first().pairedAt)
        assertTrue(repository.isConfigured())
    }
}
