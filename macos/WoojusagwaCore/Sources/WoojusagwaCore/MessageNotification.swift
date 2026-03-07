import Foundation
import UserNotifications

public enum MessageNotificationAction {
    public static let categoryIdentifier = "WOOJUSAGWA_OTP_COPY"
    public static let copyOtpActionIdentifier = "WOOJUSAGWA_COPY_OTP"
    public static let otpCodeUserInfoKey = "otpCode"
}

public struct OneTimeCodeDetector {
    private let keywordPattern = #"(otp|verification|verify|passcode|code|인증|인증번호|보안코드|확인코드|認証|認証コード|認証番号|確認コード|ワンタイムパスワード|验证码|驗證碼|验证|驗證|校验码|校驗碼|动态码|動態碼)"#
    private let codePattern = #"(?<!\d)\d{4,8}(?!\d)"#

    public init() {}

    public func detect(in text: String) -> String? {
        let range = NSRange(text.startIndex..., in: text)

        guard let keywordExpression = try? NSRegularExpression(pattern: keywordPattern, options: [.caseInsensitive]),
              keywordExpression.firstMatch(in: text, options: [], range: range) != nil,
              let codeExpression = try? NSRegularExpression(pattern: codePattern),
              let match = codeExpression.firstMatch(in: text, options: [], range: range),
              let matchRange = Range(match.range, in: text) else {
            return nil
        }

        return String(text[matchRange])
    }
}

public struct MessageNotificationRequestFactory {
    private let codeDetector: OneTimeCodeDetector
    private let deliveryDelay: TimeInterval

    public init(
        codeDetector: OneTimeCodeDetector = OneTimeCodeDetector(),
        deliveryDelay: TimeInterval = 1
    ) {
        self.codeDetector = codeDetector
        self.deliveryDelay = deliveryDelay
    }

    public var foregroundPresentationOptions: UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    public func makeRequest(
        title: String,
        body: String,
        identifier: String = UUID().uuidString
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        if let otpCode = codeDetector.detect(in: [title, body].joined(separator: "\n")) {
            content.categoryIdentifier = MessageNotificationAction.categoryIdentifier
            content.userInfo[MessageNotificationAction.otpCodeUserInfoKey] = otpCode
        }

        return UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: deliveryDelay, repeats: false)
        )
    }
}

public struct MessageNotificationAuthorizationPlan {
    public init() {}

    public var defaultRequestOptions: UNAuthorizationOptions {
        [.alert, .badge, .sound, .providesAppNotificationSettings]
    }

    public func statusText(
        authorizationStatus: UNAuthorizationStatus,
        alertSetting: UNNotificationSetting,
        notificationCenterSetting: UNNotificationSetting,
        languageCode: String? = nil
    ) -> String {
        switch authorizationStatus {
        case .notDetermined:
            return AppText.pick(
                ko: "알림 권한 필요",
                en: "Notification permission required",
                languageCode: languageCode
            )
        case .denied:
            return AppText.pick(
                ko: "알림 꺼짐: macOS 설정에서 우주사과 알림을 허용해 주세요.",
                en: "Notifications are off. Allow Woojusagwa in macOS settings.",
                languageCode: languageCode
            )
        case .provisional:
            return AppText.pick(
                ko: "임시 허용 상태입니다. 알림 설정에서 배너 또는 알림으로 바꿔 주세요.",
                en: "Notifications are provisionally allowed. Switch to banners or alerts in settings.",
                languageCode: languageCode
            )
        case .authorized, .ephemeral:
            let alertEnabled = alertSetting == .enabled
            let centerEnabled = notificationCenterSetting == .enabled

            if alertEnabled && centerEnabled {
                return AppText.pick(
                    ko: "배너와 알림센터 사용 가능",
                    en: "Banners and Notification Center enabled",
                    languageCode: languageCode
                )
            }

            if alertEnabled {
                return AppText.pick(
                    ko: "배너만 켜짐: 알림센터 저장은 꺼져 있을 수 있습니다.",
                    en: "Banners enabled. Notification Center may still be off.",
                    languageCode: languageCode
                )
            }

            if centerEnabled {
                return AppText.pick(
                    ko: "알림센터만 켜짐: 배너는 꺼져 있습니다.",
                    en: "Notification Center enabled. Banners are off.",
                    languageCode: languageCode
                )
            }

            return AppText.pick(
                ko: "권한 있음, 하지만 배너/알림센터 표시가 꺼져 있습니다.",
                en: "Permission granted, but banners and Notification Center are off.",
                languageCode: languageCode
            )
        @unknown default:
            return AppText.pick(
                ko: "알림 상태를 확인할 수 없습니다.",
                en: "Unable to determine notification status.",
                languageCode: languageCode
            )
        }
    }
}
