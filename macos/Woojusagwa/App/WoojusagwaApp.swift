import SwiftUI
import AppKit
import Combine

@main
struct WoojusagwaApp: App {
    private let subscriber: NtfySubscriber
    private let launchAtLoginController: LaunchAtLoginController

    init() {
        let appLanguageStore = AppLanguageStore()
        AppText.preferredLanguageCodeProvider = {
            appLanguageStore.currentLanguage().tag
        }
        let notificationManager = NotificationManager()
        let pairingStore = PairingConfigurationStore()
        let deviceIdentityStore = DeviceIdentityStore()
        let subscriber = NtfySubscriber(
            pairingStore: pairingStore,
            notificationManager: notificationManager,
            deviceIdentityStore: deviceIdentityStore,
            appLanguageStore: appLanguageStore
        )
        let launchAtLoginController = LaunchAtLoginController(
            preferenceStore: LaunchAtLoginPreferenceStore()
        )
        self.subscriber = subscriber
        self.launchAtLoginController = launchAtLoginController

        // macOS 26.4 can fail to present MenuBarExtra window scenes for LSUIElement apps.
        // Drive the menu bar UI with NSStatusItem + NSPopover directly to keep the panel reliable.
        DispatchQueue.main.async {
            MenuBarController.shared.install(
                content: MenuBarView(
                    subscriber: subscriber,
                    launchAtLoginController: launchAtLoginController
                ),
                subscriber: subscriber
            )
        }
    }

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

private final class MenuBarController: NSObject {
    static let shared = MenuBarController()

    private let popover = NSPopover()
    private var statusItem: NSStatusItem?
    private var languageObserver: AnyCancellable?

    private override init() {
        super.init()
        popover.behavior = .transient
        popover.animates = false
    }

    func install<Content: View>(content: Content, subscriber: NtfySubscriber) {
        let statusItem = statusItem ?? NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        self.statusItem = statusItem
        configureButton(for: statusItem)

        let hostingController = NSHostingController(rootView: AnyView(content))
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 372, height: 660)
        popover.contentViewController = hostingController
        popover.contentSize = NSSize(width: 400, height: 660)

        languageObserver = subscriber.$selectedLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] language in
                self?.updateButtonLocalization(languageCode: language.tag)
            }

        updateButtonLocalization(languageCode: subscriber.selectedLanguage.tag)
    }

    private func configureButton(for statusItem: NSStatusItem) {
        guard let button = statusItem.button else {
            return
        }

        let image = NSImage(
            systemSymbolName: "message.badge.waveform",
            accessibilityDescription: nil
        )
        image?.isTemplate = true

        button.image = image
        button.target = self
        button.action = #selector(togglePopover(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    private func updateButtonLocalization(languageCode: String) {
        statusItem?.button?.toolTip = AppText.pick(
            ko: "우주사과",
            en: "Woojusagwa",
            languageCode: languageCode
        )
    }

    @objc
    private func togglePopover(_ sender: Any?) {
        guard let button = statusItem?.button else {
            return
        }

        if popover.isShown {
            popover.performClose(sender)
            return
        }

        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        popover.contentViewController?.view.window?.makeKey()
    }
}
