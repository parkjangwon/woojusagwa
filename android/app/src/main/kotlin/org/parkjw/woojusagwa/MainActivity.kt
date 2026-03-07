package org.parkjw.woojusagwa

import android.os.Bundle
import android.widget.Button
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import com.journeyapps.barcodescanner.ScanContract
import com.journeyapps.barcodescanner.ScanOptions
import org.parkjw.woojusagwa.pairing.PairingPayloadParser
import org.parkjw.woojusagwa.settings.NotificationAccessShortcut
import org.parkjw.woojusagwa.settings.SettingsRepository

class MainActivity : AppCompatActivity() {

    private lateinit var settings: SettingsRepository
    private lateinit var statusText: TextView
    private val pairingPayloadParser = PairingPayloadParser()

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
        val permissionButton: Button = findViewById(R.id.permission_button)

        updateStatus()

        scanButton.setOnClickListener {
            val options = ScanOptions()
            options.setDesiredBarcodeFormats(ScanOptions.QR_CODE)
            options.setPrompt("Scan Mac QR Code")
            options.setBeepEnabled(false)
            barcodeLauncher.launch(options)
        }

        permissionButton.setOnClickListener {
            startActivity(NotificationAccessShortcut.createIntent())
        }
    }

    private fun updateStatus() {
        if (settings.isConfigured()) {
            statusText.text = getString(
                R.string.status_connected,
                settings.getServer(),
                settings.getTopic()
            )
        } else {
            statusText.text = getString(R.string.status_not_paired)
        }
    }

    private fun handlePairing(qrData: String) {
        val payload = pairingPayloadParser.parse(qrData)

        if (payload == null) {
            statusText.text = getString(R.string.status_invalid_qr)
            return
        }

        settings.setTopic(payload.topic)
        settings.setServer(payload.server)
        updateStatus()
    }
}
