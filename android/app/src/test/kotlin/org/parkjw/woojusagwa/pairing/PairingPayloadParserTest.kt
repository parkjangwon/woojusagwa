package org.parkjw.woojusagwa.pairing

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class PairingPayloadParserTest {

    @Test
    fun `parses valid pairing payload`() {
        val parser = PairingPayloadParser()

        val payload = parser.parse("""{"version":1,"server":"https://ntfy.sh","topic":"ws_apple"}""")

        assertEquals(1, payload?.version)
        assertEquals("https://ntfy.sh", payload?.server)
        assertEquals("ws_apple", payload?.topic)
    }

    @Test
    fun `uses default server when server is missing`() {
        val parser = PairingPayloadParser()

        val payload = parser.parse("""{"version":1,"topic":"ws_apple"}""")

        assertEquals("https://ntfy.sh", payload?.server)
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

        val payload = parser.parse("""{"version":2,"server":"https://ntfy.sh","topic":"ws_apple"}""")

        assertNull(payload)
    }
}
