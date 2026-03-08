import SwiftUI

@main
struct WoojusagwaApp: App {
    @StateObject private var subscriber: NtfySubscriber
    @StateObject private var launchAtLoginController: LaunchAtLoginController

    init() {
        let appLanguageStore = AppLanguageStore()
        AppText.preferredLanguageCodeProvider = {
            appLanguageStore.currentLanguage().tag
        }
        let notificationManager = NotificationManager()
        let pairingStore = PairingConfigurationStore()
        let deviceIdentityStore = DeviceIdentityStore()
        _subscriber = StateObject(
            wrappedValue: NtfySubscriber(
                pairingStore: pairingStore,
                notificationManager: notificationManager,
                deviceIdentityStore: deviceIdentityStore,
                appLanguageStore: appLanguageStore
            )
        )
        _launchAtLoginController = StateObject(
            wrappedValue: LaunchAtLoginController(
                preferenceStore: LaunchAtLoginPreferenceStore()
            )
        )
    }
    
    var body: some Scene {
        MenuBarExtra(
            AppText.pick(
                ko: "우주사과",
                en: "Woojusagwa",
                languageCode: subscriber.selectedLanguage.tag
            ),
            systemImage: "message.badge.waveform"
        ) {
            MenuBarView(
                subscriber: subscriber,
                launchAtLoginController: launchAtLoginController
            )
        }
        .menuBarExtraStyle(.window)
    }
}
