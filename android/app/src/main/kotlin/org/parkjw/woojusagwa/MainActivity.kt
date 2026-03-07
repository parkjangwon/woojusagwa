package org.parkjw.woojusagwa

import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.AppCompatDelegate
import androidx.appcompat.widget.SwitchCompat
import androidx.core.os.LocaleListCompat
import com.journeyapps.barcodescanner.ScanContract
import com.journeyapps.barcodescanner.ScanOptions
import com.google.android.material.button.MaterialButtonToggleGroup
import org.parkjw.woojusagwa.pairing.PairingPayloadParser
import org.parkjw.woojusagwa.settings.AppLanguage
import org.parkjw.woojusagwa.settings.AppLanguageStore
import org.parkjw.woojusagwa.settings.NotificationAccessShortcut
import org.parkjw.woojusagwa.settings.PairedMac
import org.parkjw.woojusagwa.settings.SettingsRepository

class MainActivity : AppCompatActivity() {

    private lateinit var settings: SettingsRepository
    private lateinit var languageStore: AppLanguageStore
    private lateinit var statusText: TextView
    private lateinit var versionText: TextView
    private lateinit var pairedMacsContainer: LinearLayout
    private lateinit var pairedMacsEmptyText: TextView
    private lateinit var languageToggleGroup: MaterialButtonToggleGroup
    private val pairingPayloadParser = PairingPayloadParser()
    private val stateFactory = MainActivityStateFactory()

    private val barcodeLauncher = registerForActivityResult(ScanContract()) { result ->
        if (result.contents != null) {
            handlePairing(result.contents)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        settings = SettingsRepository(this)
        languageStore = AppLanguageStore(this)
        statusText = findViewById(R.id.status_text)
        versionText = findViewById(R.id.version_text)
        pairedMacsContainer = findViewById(R.id.paired_macs_container)
        pairedMacsEmptyText = findViewById(R.id.paired_macs_empty_text)
        languageToggleGroup = findViewById(R.id.language_toggle_group)
        val scanButton: Button = findViewById(R.id.scan_button)
        val permissionButton: Button = findViewById(R.id.permission_button)

        bindLanguageToggle()
        renderState()

        scanButton.setOnClickListener {
            val options = ScanOptions()
            options.setDesiredBarcodeFormats(ScanOptions.QR_CODE)
            options.setPrompt(getString(R.string.qr_prompt))
            options.setBeepEnabled(false)
            options.setOrientationLocked(false)
            barcodeLauncher.launch(options)
        }

        permissionButton.setOnClickListener {
            startActivity(NotificationAccessShortcut.createIntent())
        }
    }

    private fun bindLanguageToggle() {
        val selectedButtonId = when (languageStore.currentLanguage()) {
            AppLanguage.ENGLISH -> R.id.language_english_button
            AppLanguage.KOREAN -> R.id.language_korean_button
        }

        languageToggleGroup.check(selectedButtonId)
        languageToggleGroup.addOnButtonCheckedListener { _, checkedId, isChecked ->
            if (!isChecked) {
                return@addOnButtonCheckedListener
            }

            val selectedLanguage = when (checkedId) {
                R.id.language_english_button -> AppLanguage.ENGLISH
                else -> AppLanguage.KOREAN
            }

            if (selectedLanguage == languageStore.currentLanguage()) {
                return@addOnButtonCheckedListener
            }

            languageStore.setLanguage(selectedLanguage)
            AppCompatDelegate.setApplicationLocales(
                LocaleListCompat.forLanguageTags(selectedLanguage.tag)
            )
        }
    }

    private fun renderState() {
        val state = stateFactory.create(
            versionName = appVersionName(),
            versionCode = appVersionCode(),
            pairedMacs = settings.getPairedMacs(),
        )

        versionText.text = getString(
            R.string.version_value,
            state.versionName,
            state.versionCode,
        )
        statusText.text = if (state.hasPairedMacs) {
            getString(
                R.string.status_connected_summary,
                state.pairedMacCount,
                state.enabledPairedMacCount,
            )
        } else {
            getString(R.string.status_not_paired)
        }

        renderPairedMacRows(state)
    }

    private fun renderPairedMacRows(state: MainActivityState) {
        pairedMacsContainer.removeAllViews()
        pairedMacsEmptyText.visibility = if (state.hasPairedMacs) View.GONE else View.VISIBLE

        state.pairedMacRows.forEach { rowState ->
            val rowView = layoutInflater.inflate(R.layout.item_paired_mac, pairedMacsContainer, false)
            val deviceNameText: TextView = rowView.findViewById(R.id.paired_mac_name)
            val topicText: TextView = rowView.findViewById(R.id.paired_mac_topic)
            val serverText: TextView = rowView.findViewById(R.id.paired_mac_server)
            val enabledLabelText: TextView = rowView.findViewById(R.id.paired_mac_enabled_label)
            val enabledSwitch: SwitchCompat = rowView.findViewById(R.id.paired_mac_enabled_switch)
            val removeButton: Button = rowView.findViewById(R.id.paired_mac_remove_button)

            deviceNameText.text = rowState.deviceName
            topicText.text = getString(R.string.paired_mac_topic_value, rowState.topic)
            serverText.text = getString(R.string.paired_mac_server_value, rowState.server)
            enabledLabelText.text = getString(
                if (rowState.enabled) {
                    R.string.paired_mac_enabled_on
                } else {
                    R.string.paired_mac_enabled_off
                }
            )

            enabledSwitch.setOnCheckedChangeListener(null)
            enabledSwitch.isChecked = rowState.enabled
            enabledSwitch.setOnCheckedChangeListener { _, isChecked ->
                settings.setPairedMacEnabled(rowState.deviceId, isChecked)
                renderState()
            }

            removeButton.setOnClickListener {
                settings.removePairedMac(rowState.deviceId)
                renderState()
            }

            pairedMacsContainer.addView(rowView)
        }
    }

    private fun handlePairing(qrData: String) {
        val payload = pairingPayloadParser.parse(qrData)

        if (payload == null) {
            statusText.text = getString(R.string.status_invalid_qr)
            return
        }

        settings.upsertPairedMac(
            PairedMac(
                deviceId = payload.deviceId,
                deviceName = payload.deviceName,
                server = payload.server,
                topic = payload.topic,
                enabled = true,
                pairedAt = 0L,
            )
        )
        renderState()
    }

    @Suppress("DEPRECATION")
    private fun appVersionName(): String {
        val packageInfo = packageManager.getPackageInfo(packageName, 0)
        return packageInfo.versionName ?: "0.0.0"
    }

    @Suppress("DEPRECATION")
    private fun appVersionCode(): Int {
        val packageInfo = packageManager.getPackageInfo(packageName, 0)
        return packageInfo.versionCode
    }
}
