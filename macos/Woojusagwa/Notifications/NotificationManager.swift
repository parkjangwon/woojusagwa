import Foundation
import UserNotifications
import AppKit
import Combine

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published private(set) var authorizationStatusText = "알림 권한 확인 중"
    @Published private(set) var notificationsEnabled = false

    private let center: UNUserNotificationCenter
    private let requestFactory: MessageNotificationRequestFactory
    private let authorizationPlan: MessageNotificationAuthorizationPlan

    init(
        center: UNUserNotificationCenter = .current(),
        requestFactory: MessageNotificationRequestFactory = MessageNotificationRequestFactory(),
        authorizationPlan: MessageNotificationAuthorizationPlan = MessageNotificationAuthorizationPlan()
    ) {
        self.center = center
        self.requestFactory = requestFactory
        self.authorizationPlan = authorizationPlan
        super.init()
        center.delegate = self
        configureCategories()
        refreshAuthorizationStatus()
        DispatchQueue.main.async { [weak self] in
            self?.bootstrapNotificationAuthorizationIfNeeded()
        }
    }

    func show(title: String, body: String) {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .notDetermined:
                self.bootstrapNotificationAuthorization { granted in
                    if granted {
                        self.enqueueNotification(title: title, body: body)
                    }
                }
            case .authorized, .provisional, .ephemeral:
                self.enqueueNotification(title: title, body: body)
            case .denied:
                DispatchQueue.main.async {
                    self.authorizationStatusText = self.authorizationPlan.statusText(
                        authorizationStatus: settings.authorizationStatus,
                        alertSetting: settings.alertSetting,
                        notificationCenterSetting: settings.notificationCenterSetting
                    )
                    self.notificationsEnabled = false
                }
            @unknown default:
                break
            }
        }
    }

    func sendTestNotification() {
        show(
            title: "우주사과 테스트",
            body: "이 알림이 보이면 macOS 알림센터 연동이 정상입니다."
        )
    }

    func refreshAuthorizationStatus() {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            let enabled: Bool
            let statusText = self.authorizationPlan.statusText(
                authorizationStatus: settings.authorizationStatus,
                alertSetting: settings.alertSetting,
                notificationCenterSetting: settings.notificationCenterSetting
            )

            switch settings.authorizationStatus {
            case .authorized, .ephemeral:
                enabled = settings.alertSetting == .enabled || settings.notificationCenterSetting == .enabled
            case .provisional:
                enabled = true
            case .notDetermined, .denied:
                enabled = false
            @unknown default:
                enabled = false
            }

            DispatchQueue.main.async {
                self.authorizationStatusText = statusText
                self.notificationsEnabled = enabled
            }
        }
    }

    func requestNotificationAuthorization() {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .notDetermined:
                self.bootstrapNotificationAuthorization(openSettingsAfterBootstrap: true)
            case .authorized, .provisional, .ephemeral, .denied:
                self.openNotificationSettings()
                self.refreshAuthorizationStatus()
            @unknown default:
                self.refreshAuthorizationStatus()
            }
        }
    }

    func openNotificationSettings() {
        let candidateURLs = [
            URL(string: "x-apple.systempreferences:com.apple.Notifications-Settings.extension"),
            URL(string: "x-apple.systempreferences:com.apple.preference.notifications"),
            URL(fileURLWithPath: "/System/Applications/System Settings.app")
        ].compactMap { $0 }

        for url in candidateURLs where NSWorkspace.shared.open(url) {
            return
        }
    }

    private func enqueueNotification(title: String, body: String) {
        let request = requestFactory.makeRequest(title: title, body: body)

        center.add(request) { error in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            }
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler(requestFactory.foregroundPresentationOptions)
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer { completionHandler() }

        guard response.actionIdentifier == MessageNotificationAction.copyOtpActionIdentifier,
              let otpCode = response.notification.request.content.userInfo[MessageNotificationAction.otpCodeUserInfoKey] as? String else {
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(otpCode, forType: .string)
    }

    private func configureCategories() {
        let copyAction = UNNotificationAction(
            identifier: MessageNotificationAction.copyOtpActionIdentifier,
            title: "복사하기"
        )
        let category = UNNotificationCategory(
            identifier: MessageNotificationAction.categoryIdentifier,
            actions: [copyAction],
            intentIdentifiers: []
        )

        center.setNotificationCategories([category])
    }

    private func bootstrapNotificationAuthorization(
        openSettingsAfterBootstrap: Bool = false,
        completion: ((Bool) -> Void)? = nil
    ) {
        center.requestAuthorization(options: authorizationPlan.bootstrapRequestOptions) { [weak self] granted, error in
            guard let self else {
                completion?(granted)
                return
            }

            if let error {
                print("Notification bootstrap error: \(error.localizedDescription)")
            }

            if granted {
                self.enqueueBootstrapNotification()
            }

            self.refreshAuthorizationStatus()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.refreshAuthorizationStatus()
            }

            if openSettingsAfterBootstrap {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    self?.openNotificationSettings()
                }
            }

            completion?(granted)
        }
    }

    private func enqueueBootstrapNotification() {
        let identifier = MessageNotificationAuthorizationPlan.bootstrapNotificationIdentifier
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])

        let request = authorizationPlan.makeBootstrapNotificationRequest(identifier: identifier)

        center.add(request) { error in
            if let error {
                print("Error adding bootstrap notification: \(error.localizedDescription)")
            }
        }
    }

    private func bootstrapNotificationAuthorizationIfNeeded() {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .notDetermined:
                self.bootstrapNotificationAuthorization()
            case .denied:
                print("Notification Permission Denied")
            case .authorized, .provisional, .ephemeral:
                self.refreshAuthorizationStatus()
            @unknown default:
                break
            }
        }
    }
}
