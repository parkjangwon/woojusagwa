package org.parkjw.woojusagwa

import android.content.Intent
import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import org.parkjw.woojusagwa.settings.SettingsRepository
import com.journeyapps.barcodescanner.ScanContract
import com.journeyapps.barcodescanner.ScanOptions
import org.json.JSONObject

class MainActivity : AppCompatActivity() {

    private lateinit var settings: SettingsRepository
    private lateinit var statusText: TextView

    private val barcodeLauncher = registerForActivityResult(ScanContract()) { result ->
        if (result.contents != null) {
            handlePairing(result.contents)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        settings = SettingsRepository(this)
        statusText = findViewById(R.id.status_text)
        val scanButton: Button = findViewById(R.id.scan_button)

        updateStatus()

        scanButton.setOnClickListener {
            val options = ScanOptions()
            options.setDesiredBarcodeFormats(ScanOptions.QR_CODE)
            options.setPrompt("Scan Mac QR Code")
            options.setBeepEnabled(false)
            barcodeLauncher.launch(options)
        }
    }

    private fun updateStatus() {
        if (settings.isConfigured()) {
            statusText.text = "Connected: ${settings.getTopic()}"
        } else {
            statusText.text = "Status: Not Paired"
        }
    }

    private fun handlePairing(qrData: String) {
        try {
            val json = JSONObject(qrData)
            val topic = json.getString("topic")
            val server = json.optString("server", "https://ntfy.sh")
            
            settings.setTopic(topic)
            settings.setServer(server)
            
            updateStatus()
        } catch (e: Exception) {
            statusText.text = "Error: Invalid QR Code"
        }
    }
}
