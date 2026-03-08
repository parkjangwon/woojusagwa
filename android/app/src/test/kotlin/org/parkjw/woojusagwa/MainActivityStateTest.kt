package org.parkjw.woojusagwa

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.parkjw.woojusagwa.settings.PairedMac

class MainActivityStateTest {

    @Test
    fun `creates empty state with version info`() {
        val state = MainActivityStateFactory().create(
            versionName = "9.9.9",
            versionCode = 90909,
            pairedMacs = emptyList()
        )

        assertEquals("9.9.9", state.versionName)
        assertEquals(90909, state.versionCode)
        assertEquals(0, state.pairedMacCount)
        assertEquals(0, state.enabledPairedMacCount)
        assertTrue(state.pairedMacRows.isEmpty())
        assertFalse(state.hasPairedMacs)
    }

    @Test
    fun `creates row state for each paired mac`() {
        val state = MainActivityStateFactory().create(
            versionName = "9.9.9",
            versionCode = 90909,
            pairedMacs = listOf(
                PairedMac("mac-home", "개인 MacBook Pro", "https://ntfy.sh", "ws_home", true, 1_000L),
                PairedMac("mac-work", "회사 MacBook Air", "https://relay.example", "ws_work", false, 2_000L)
            )
        )

        assertEquals(2, state.pairedMacCount)
        assertEquals(1, state.enabledPairedMacCount)
        assertTrue(state.hasPairedMacs)
        assertEquals("개인 MacBook Pro", state.pairedMacRows[0].deviceName)
        assertTrue(state.pairedMacRows[0].enabled)
        assertEquals("회사 MacBook Air", state.pairedMacRows[1].deviceName)
        assertFalse(state.pairedMacRows[1].enabled)
    }
}
