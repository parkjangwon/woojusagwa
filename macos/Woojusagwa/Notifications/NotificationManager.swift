import Foundation
import UserNotifications
import AppKit

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
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
        requestAuthorizationIfNeeded()
    }

    func show(title: String, body: String) {
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

    private func requestAuthorizationIfNeeded() {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .notDetermined:
                self.center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if granted {
                        print("Notification Permission Granted")
                    } else {
                        print("Notification Permission Denied: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            case .denied:
                print("Notification Permission Denied")
            case .authorized, .provisional, .ephemeral:
                break
            @unknown default:
                break
            }
        }
    }
}
