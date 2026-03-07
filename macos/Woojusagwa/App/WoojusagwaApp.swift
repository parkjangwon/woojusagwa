import SwiftUI

@main
struct WoojusagwaApp: App {
    @StateObject private var subscriber: NtfySubscriber

    init() {
        let notificationManager = NotificationManager()
        let pairingStore = PairingConfigurationStore()
        _subscriber = StateObject(
            wrappedValue: NtfySubscriber(
                pairingStore: pairingStore,
                notificationManager: notificationManager
            )
        )
    }
    
    var body: some Scene {
        MenuBarExtra("Woojusagwa", systemImage: "message.badge.waveform") {
            MenuBarView(subscriber: subscriber)
        }
        .menuBarExtraStyle(.window)
    }
}
