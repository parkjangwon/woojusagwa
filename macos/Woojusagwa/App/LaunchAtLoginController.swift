import Foundation
import ServiceManagement

protocol LaunchAtLoginControlling {
    func currentStatus() -> SMAppService.Status
    func enable() throws
    func disable() throws
}

struct SystemLaunchAtLoginService: LaunchAtLoginControlling {
    func currentStatus() -> SMAppService.Status {
        SMAppService.mainApp.status
    }

    func enable() throws {
        try SMAppService.mainApp.register()
    }

    func disable() throws {
        try SMAppService.mainApp.unregister()
    }
}

final class LaunchAtLoginController: ObservableObject {
    @Published private(set) var isEnabled: Bool
    @Published private(set) var statusText: String

    private let service: any LaunchAtLoginControlling
    private let preferenceStore: LaunchAtLoginPreferenceStore

    init(
        service: any LaunchAtLoginControlling = SystemLaunchAtLoginService(),
        preferenceStore: LaunchAtLoginPreferenceStore = LaunchAtLoginPreferenceStore()
    ) {
        self.service = service
        self.preferenceStore = preferenceStore
        self.isEnabled = preferenceStore.isEnabled()
        self.statusText = ""
        refresh()
    }

    func refresh() {
        let status = service.currentStatus()
        apply(status: status)
    }

    func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try service.enable()
            } else {
                try service.disable()
            }
            preferenceStore.setEnabled(enabled)
            refresh()
        } catch {
            isEnabled = preferenceStore.isEnabled()
            statusText = AppText.pick(
                ko: "자동 실행 설정을 변경하지 못했습니다. 다시 시도해 주세요.",
                en: "Could not change the launch at login setting. Please try again."
            )
        }
    }

    private func apply(status: SMAppService.Status) {
        switch status {
        case .enabled:
            isEnabled = true
            preferenceStore.setEnabled(true)
            statusText = AppText.pick(
                ko: "로그인 후 자동으로 메뉴바에서 시작됩니다.",
                en: "The app will start automatically in the menu bar after login."
            )
        case .requiresApproval:
            isEnabled = true
            preferenceStore.setEnabled(true)
            statusText = AppText.pick(
                ko: "자동 실행 승인 대기 중입니다. 시스템 설정에서 허용해 주세요.",
                en: "Launch at login is waiting for approval in System Settings."
            )
        case .notRegistered:
            isEnabled = false
            preferenceStore.setEnabled(false)
            statusText = AppText.pick(
                ko: "현재 로그인 시 자동 실행이 꺼져 있습니다.",
                en: "Launch at login is currently turned off."
            )
        case .notFound:
            isEnabled = preferenceStore.isEnabled()
            statusText = AppText.pick(
                ko: "로그인 항목을 찾지 못했습니다. 앱을 다시 설치한 뒤 다시 시도해 주세요.",
                en: "The login item could not be found. Reinstall the app and try again."
            )
        @unknown default:
            isEnabled = preferenceStore.isEnabled()
            statusText = AppText.pick(
                ko: "자동 실행 상태를 확인할 수 없습니다.",
                en: "The launch at login state could not be determined."
            )
        }
    }
}
