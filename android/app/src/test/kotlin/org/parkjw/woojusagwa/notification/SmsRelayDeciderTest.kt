package org.parkjw.woojusagwa.notification

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SmsRelayDeciderTest {

    @Test
    fun `allows samsung messages with body`() {
        val decider = SmsRelayDecider()

        val shouldRelay = decider.shouldRelay(
            sourceApp = "com.samsung.android.messaging",
            title = "Alice",
            body = "Landing in 10",
            receivedAtMillis = 1_000L
        )

        assertTrue(shouldRelay)
    }

    @Test
    fun `rejects non sms app`() {
        val decider = SmsRelayDecider()

        val shouldRelay = decider.shouldRelay(
            sourceApp = "com.instagram.android",
            title = "Alice",
            body = "Landing in 10",
            receivedAtMillis = 1_000L
        )

        assertFalse(shouldRelay)
    }

    @Test
    fun `rejects blank body`() {
        val decider = SmsRelayDecider()

        val shouldRelay = decider.shouldRelay(
            sourceApp = "com.google.android.apps.messaging",
            title = "Alice",
            body = "   ",
            receivedAtMillis = 1_000L
        )

        assertFalse(shouldRelay)
    }

    @Test
    fun `suppresses duplicate message within window`() {
        val decider = SmsRelayDecider()

        assertTrue(
            decider.shouldRelay(
                sourceApp = "com.google.android.apps.messaging",
                title = "Alice",
                body = "Landing in 10",
                receivedAtMillis = 1_000L
            )
        )

        assertFalse(
            decider.shouldRelay(
                sourceApp = "com.google.android.apps.messaging",
                title = "Alice",
                body = "Landing in 10",
                receivedAtMillis = 3_000L
            )
        )
    }

    @Test
    fun `allows repeated body after dedupe window`() {
        val decider = SmsRelayDecider()

        assertTrue(
            decider.shouldRelay(
                sourceApp = "com.google.android.apps.messaging",
                title = "Alice",
                body = "Landing in 10",
                receivedAtMillis = 1_000L
            )
        )

        assertTrue(
            decider.shouldRelay(
                sourceApp = "com.google.android.apps.messaging",
                title = "Alice",
                body = "Landing in 10",
                receivedAtMillis = 5_500L
            )
        )
    }
}
