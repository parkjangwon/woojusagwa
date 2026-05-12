import AppKit
import Combine
import OSLog
import SwiftUI

@main
private enum WoojusagwaMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory)
        app.run()
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let logger = Logger(subsystem: "org.parkjw.woojusagwa.macos", category: "AppDelegate")
    private var subscriber: NtfySubscriber?
    private var launchAtLoginController: LaunchAtLoginController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        logger.info("Woojusagwa did finish launching")

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

        // Keep the app fully menubar-only. Using a SwiftUI Settings scene here
        // can restore an empty preferences window after login or restart.
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

    func applicationWillTerminate(_ notification: Notification) {
        subscriber?.disconnect()
    }
}

private final class MenuBarController: NSObject {
    static let shared = MenuBarController()

    private let logger = Logger(subsystem: "org.parkjw.woojusagwa.macos", category: "MenuBarController")
    private let popover = NSPopover()
    private var statusItem: NSStatusItem?
    private var installAttempts = 0
    private var languageObserver: AnyCancellable?

    private override init() {
        super.init()
        popover.behavior = .transient
        popover.animates = false
    }

    func install<Content: View>(content: Content, subscriber: NtfySubscriber) {
        let statusItem = statusItem ?? NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        // Preserve the identity used by the previous SwiftUI MenuBarExtra so
        // macOS/Bartender do not treat the replacement as a brand-new item.
        statusItem.autosaveName = NSStatusItem.AutosaveName("Item-0")
        self.statusItem = statusItem

        let hostingController = NSHostingController(rootView: AnyView(content))
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 372, height: 660)
        popover.contentViewController = hostingController
        popover.contentSize = NSSize(width: 400, height: 660)

        languageObserver = subscriber.$selectedLanguage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] language in
                self?.updateButtonLocalization(languageCode: language.tag)
            }

        installAttempts = 0
        logger.info("Installing status item with autosaveName=\(statusItem.autosaveName ?? "nil", privacy: .public)")
        configureButtonWhenReady(languageCode: subscriber.selectedLanguage.tag)
    }

    private func configureButtonWhenReady(languageCode: String) {
        guard let statusItem else {
            return
        }

        guard let button = statusItem.button else {
            guard installAttempts < 5 else {
                logger.error("Status item button was not available after \(self.installAttempts, privacy: .public) retries")
                return
            }

            installAttempts += 1
            logger.warning("Status item button unavailable, retry=\(self.installAttempts, privacy: .public)")
            DispatchQueue.main.async { [weak self] in
                self?.configureButtonWhenReady(languageCode: languageCode)
            }
            return
        }

        let image = NSImage(
            systemSymbolName: "message.badge.waveform",
            accessibilityDescription: nil
        )
        image?.isTemplate = true

        statusItem.length = NSStatusItem.variableLength
        statusItem.isVisible = true
        button.identifier = NSUserInterfaceItemIdentifier("org.parkjw.woojusagwa.macos.statusItem")
        button.font = .systemFont(ofSize: 12, weight: .semibold)
        button.isEnabled = true
        button.isHidden = false
        button.appearsDisabled = false
        button.title = AppText.pick(
            ko: "우주",
            en: "WS",
            languageCode: languageCode
        )
        button.image = image
        button.imagePosition = image == nil ? .noImage : .imageLeading
        button.target = self
        button.action = #selector(togglePopover(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        updateButtonLocalization(languageCode: languageCode)
        logger.info("Status item configured title=\(button.title, privacy: .public) hasImage=\(button.image != nil, privacy: .public) visible=\(statusItem.isVisible, privacy: .public)")
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
