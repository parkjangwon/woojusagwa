package org.parkjw.woojusagwa.relay

import android.content.Context
import android.util.Log
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.parkjw.woojusagwa.settings.SettingsRepository
import java.io.IOException

class NtfyPublisher(private val context: Context) {

    private val TAG = "NtfyPublisher"
    private val client = OkHttpClient()
    private val settings = SettingsRepository(context)

    fun publish(payload: String) {
        val server = settings.getServer()
        val topic = settings.getTopic()

        if (topic.isEmpty()) {
            Log.e(TAG, "Topic is empty, cannot publish")
            return
        }

        val url = "$server/$topic"
        val mediaType = "application/json; charset=utf-8".toMediaType()
        val requestBody = payload.toRequestBody(mediaType)

        val request = Request.Builder()
            .url(url)
            .post(requestBody)
            .build()

        client.newCall(request).enqueue(object : okhttp3.Callback {
            override fun onFailure(call: okhttp3.Call, e: IOException) {
                Log.e(TAG, "Failed to publish message: ${e.message}")
            }

            override fun onResponse(call: okhttp3.Call, response: okhttp3.Response) {
                if (!response.isSuccessful) {
                    Log.e(TAG, "Server returned error: ${response.code}")
                } else {
                    Log.d(TAG, "Successfully published message to topic: $topic")
                }
                response.close()
            }
        })
    }
}
