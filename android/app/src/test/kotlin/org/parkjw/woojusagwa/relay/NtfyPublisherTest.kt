package org.parkjw.woojusagwa.relay

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Test
import org.junit.runner.RunWith
import org.parkjw.woojusagwa.settings.PairedMac
import org.parkjw.woojusagwa.settings.SettingsRepository
import org.robolectric.RobolectricTestRunner
import java.io.IOException

@RunWith(RobolectricTestRunner::class)
class NtfyPublisherTest {

    @Test
    fun `publishes one payload to every enabled paired mac`() {
        val repository = testRepository()
        repository.upsertPairedMac(
            PairedMac("mac-home", "개인 MacBook Pro", "https://ntfy.sh", "ws_home", true, 1_000L)
        )
        repository.upsertPairedMac(
            PairedMac("mac-work", "회사 MacBook Air", "https://relay.example", "ws_work", true, 2_000L)
        )
        val transport = RecordingTransport()
        val publisher = NtfyPublisher(repository, transport)

        publisher.publish("""{"title":"Alice","body":"Landing in 10"}""")

        assertEquals(
            listOf(
                "https://ntfy.sh/ws_home",
                "https://relay.example/ws_work"
            ),
            transport.urls
        )
        assertEquals(2, transport.payloads.size)
    }

    @Test
    fun `skips disabled paired macs`() {
        val repository = testRepository()
        repository.upsertPairedMac(
            PairedMac("mac-home", "개인 MacBook Pro", "https://ntfy.sh", "ws_home", true, 1_000L)
        )
        repository.upsertPairedMac(
            PairedMac("mac-work", "회사 MacBook Air", "https://relay.example", "ws_work", false, 2_000L)
        )
        val transport = RecordingTransport()
        val publisher = NtfyPublisher(repository, transport)

        publisher.publish("""{"title":"Alice","body":"Landing in 10"}""")

        assertEquals(listOf("https://ntfy.sh/ws_home"), transport.urls)
    }

    @Test
    fun `continues publishing when one target fails`() {
        val repository = testRepository()
        repository.upsertPairedMac(
            PairedMac("mac-home", "개인 MacBook Pro", "https://ntfy.sh", "ws_home", true, 1_000L)
        )
        repository.upsertPairedMac(
            PairedMac("mac-work", "회사 MacBook Air", "https://relay.example", "ws_work", true, 2_000L)
        )
        val transport = RecordingTransport(failingUrl = "https://ntfy.sh/ws_home")
        val publisher = NtfyPublisher(repository, transport)

        publisher.publish("""{"title":"Alice","body":"Landing in 10"}""")

        assertEquals(
            listOf(
                "https://ntfy.sh/ws_home",
                "https://relay.example/ws_work"
            ),
            transport.urls
        )
    }

    private fun testRepository(): SettingsRepository {
        val context = ApplicationProvider.getApplicationContext<Context>()
        val prefs = context.getSharedPreferences("woojusagwa_publisher_test", Context.MODE_PRIVATE)
        prefs.edit().clear().commit()
        return SettingsRepository(prefs, nowProvider = { 1_000L })
    }
}

private class RecordingTransport(
    private val failingUrl: String? = null,
) : NtfyPublishTransport {
    val urls = mutableListOf<String>()
    val payloads = mutableListOf<String>()

    override fun publish(url: String, payload: String) {
        urls.add(url)
        payloads.add(payload)

        if (url == failingUrl) {
            throw IOException("Simulated publish failure")
        }
    }
}
