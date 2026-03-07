import SwiftUI

@main
struct WoojusagwaApp: App {
    @StateObject private var subscriber: NtfySubscriber

    init() {
        let notificationManager = NotificationManager()
        let pairingStore = PairingConfigurationStore()
        let deviceIdentityStore = DeviceIdentityStore()
        _subscriber = StateObject(
            wrappedValue: NtfySubscriber(
                pairingStore: pairingStore,
                notificationManager: notificationManager,
                deviceIdentityStore: deviceIdentityStore
            )
        )
    }
    
    var body: some Scene {
        MenuBarExtra(AppText.pick(ko: "우주사과", en: "Woojusagwa"), systemImage: "message.badge.waveform") {
            MenuBarView(subscriber: subscriber)
        }
        .menuBarExtraStyle(.window)
    }
}
