package org.parkjw.woojusagwa.relay

import android.content.Context
import android.util.Log
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.parkjw.woojusagwa.settings.PairedMac
import org.parkjw.woojusagwa.settings.SettingsRepository
import java.io.IOException

interface NtfyPublishTransport {
    fun publish(url: String, payload: String)
}

class NtfyPublisher(
    private val settings: SettingsRepository,
    private val transport: NtfyPublishTransport = OkHttpNtfyPublishTransport(),
) {

    constructor(context: Context) : this(SettingsRepository(context))

    fun publish(payload: String) {
        val pairedMacs = settings.getEnabledPairedMacs()

        if (pairedMacs.isEmpty()) {
            Log.e(TAG, "No enabled paired Macs, cannot publish")
            return
        }

        pairedMacs.forEach { pairedMac ->
            publishToTarget(pairedMac, payload)
        }
    }

    private fun publishToTarget(pairedMac: PairedMac, payload: String) {
        val normalizedServer = pairedMac.server.trimEnd('/')
        val url = "$normalizedServer/${pairedMac.topic}"

        try {
            transport.publish(url, payload)
        } catch (error: IOException) {
            Log.e(TAG, "Failed to publish message to ${pairedMac.deviceName}: ${error.message}")
        } catch (error: RuntimeException) {
            Log.e(TAG, "Unexpected publish error for ${pairedMac.deviceName}: ${error.message}")
        }
    }

    companion object {
        private const val TAG = "NtfyPublisher"
    }
}

class OkHttpNtfyPublishTransport(
    private val client: OkHttpClient = OkHttpClient(),
) : NtfyPublishTransport {
    private val mediaType = "application/json; charset=utf-8".toMediaType()

    override fun publish(url: String, payload: String) {
        val request = Request.Builder()
            .url(url)
            .post(payload.toRequestBody(mediaType))
            .build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: IOException) {
                Log.e("NtfyPublisher", "Failed to publish message: ${e.message}")
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (!response.isSuccessful) {
                    Log.e("NtfyPublisher", "Server returned error: ${response.code}")
                } else {
                    Log.d("NtfyPublisher", "Successfully published relay message")
                }
                response.close()
            }
        })
    }
}
