import SwiftUI

@main
struct WoojusagwaApp: App {
    @StateObject private var subscriber = NtfySubscriber()
    
    var body: some Scene {
        MenuBarExtra("Woojusagwa", systemImage: "applelogo") {
            MenuBarView(subscriber: subscriber)
        }
        .menuBarExtraStyle(.window)
    }
}
