import Foundation
import UserNotifications
import AppKit
import Combine

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published private(set) var authorizationStatusText = "알림 권한 확인 중"
    @Published private(set) var notificationsEnabled = false

    private let center: UNUserNotificationCenter
    private let requestFactory: MessageNotificationRequestFactory

    init(
        center: UNUserNotificationCenter = .current(),
        requestFactory: MessageNotificationRequestFactory = MessageNotificationRequestFactory()
    ) {
        self.center = center
        self.requestFactory = requestFactory
        super.init()
        center.delegate = self
        configureCategories()
        refreshAuthorizationStatus()
        requestAuthorizationIfNeeded()
    }

    func show(title: String, body: String) {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorizationInteractively { granted in
                    if granted {
                        self.enqueueNotification(title: title, body: body)
                    }
                }
            case .authorized, .provisional, .ephemeral:
                self.enqueueNotification(title: title, body: body)
            case .denied:
                DispatchQueue.main.async {
                    self.authorizationStatusText = "알림 꺼짐: macOS 설정에서 우주사과 알림을 허용해 주세요."
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

            let statusText: String
            let enabled: Bool

            switch settings.authorizationStatus {
            case .notDetermined:
                statusText = "알림 권한 필요"
                enabled = false
            case .denied:
                statusText = "알림 꺼짐: macOS 설정에서 우주사과 알림을 허용해 주세요."
                enabled = false
            case .authorized, .provisional, .ephemeral:
                let alertEnabled = settings.alertSetting == .enabled
                let centerEnabled = settings.notificationCenterSetting == .enabled

                if alertEnabled && centerEnabled {
                    statusText = "배너와 알림센터 사용 가능"
                    enabled = true
                } else if alertEnabled {
                    statusText = "배너만 켜짐: 알림센터 저장은 꺼져 있을 수 있습니다."
                    enabled = true
                } else if centerEnabled {
                    statusText = "알림센터만 켜짐: 배너는 꺼져 있습니다."
                    enabled = true
                } else {
                    statusText = "권한 있음, 하지만 배너/알림센터 표시가 꺼져 있습니다."
                    enabled = false
                }
            @unknown default:
                statusText = "알림 상태를 확인할 수 없습니다."
                enabled = false
            }

            DispatchQueue.main.async {
                self.authorizationStatusText = statusText
                self.notificationsEnabled = enabled
            }
        }
    }

    func requestNotificationAuthorization() {
        requestAuthorizationInteractively { [weak self] _ in
            self?.refreshAuthorizationStatus()
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

    private func requestAuthorizationInteractively(completion: ((Bool) -> Void)? = nil) {
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
        }

        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            if granted {
                print("Notification Permission Granted")
            } else {
                print("Notification Permission Denied: \(error?.localizedDescription ?? "Unknown error")")
            }

            self?.refreshAuthorizationStatus()
            completion?(granted)
        }
    }

    private func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorizationInteractively()
            case .denied:
                print("Notification Permission Denied")
            case .authorized, .provisional, .ephemeral:
                self.refreshAuthorizationStatus()
                break
            @unknown default:
                break
            }
        }
    }
}
