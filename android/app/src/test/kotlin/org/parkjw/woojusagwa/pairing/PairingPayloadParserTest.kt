package org.parkjw.woojusagwa.pairing

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class PairingPayloadParserTest {

    @Test
    fun `parses v2 pairing payload with device metadata`() {
        val parser = PairingPayloadParser()

        val payload = parser.parse(
            """
            {"version":2,"server":"https://ntfy.sh","topic":"ws_apple","device_id":"mac-123","device_name":"개인 MacBook Pro"}
            """.trimIndent()
        )

        assertEquals(2, payload?.version)
        assertEquals("https://ntfy.sh", payload?.server)
        assertEquals("ws_apple", payload?.topic)
        assertEquals("mac-123", payload?.deviceId)
        assertEquals("개인 MacBook Pro", payload?.deviceName)
    }

    @Test
    fun `still accepts v1 pairing payload`() {
        val parser = PairingPayloadParser()

        val payload = parser.parse("""{"version":1,"topic":"ws_apple"}""")

        assertEquals(1, payload?.version)
        assertEquals("https://ntfy.sh", payload?.server)
        assertEquals("ws_apple", payload?.topic)
        assertEquals("legacy-ws_apple", payload?.deviceId)
        assertEquals("기존 Mac", payload?.deviceName)
    }

    @Test
    fun `rejects payload without topic`() {
        val parser = PairingPayloadParser()

        val payload = parser.parse("""{"version":1,"server":"https://ntfy.sh"}""")

        assertNull(payload)
    }

    @Test
    fun `rejects unsupported version`() {
        val parser = PairingPayloadParser()

        val payload = parser.parse("""{"version":3,"server":"https://ntfy.sh","topic":"ws_apple"}""")

        assertNull(payload)
    }
}
