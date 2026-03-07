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
    public static let bootstrapNotificationIdentifier = "org.parkjw.woojusagwa.notification.bootstrap"

    public init() {}

    public var bootstrapRequestOptions: UNAuthorizationOptions {
        [.alert, .badge, .sound, .provisional, .providesAppNotificationSettings]
    }

    public var interactiveRequestOptions: UNAuthorizationOptions {
        [.alert, .badge, .sound]
    }

    public func statusText(
        authorizationStatus: UNAuthorizationStatus,
        alertSetting: UNNotificationSetting,
        notificationCenterSetting: UNNotificationSetting
    ) -> String {
        switch authorizationStatus {
        case .notDetermined:
            return "알림 권한 필요"
        case .denied:
            return "알림 꺼짐: macOS 설정에서 우주사과 알림을 허용해 주세요."
        case .provisional:
            return "임시 허용됨: 알림센터에 조용히 전달됩니다. 테스트 알림 후 유지 또는 즉시 전달로 바꿔 주세요."
        case .authorized, .ephemeral:
            let alertEnabled = alertSetting == .enabled
            let centerEnabled = notificationCenterSetting == .enabled

            if alertEnabled && centerEnabled {
                return "배너와 알림센터 사용 가능"
            }

            if alertEnabled {
                return "배너만 켜짐: 알림센터 저장은 꺼져 있을 수 있습니다."
            }

            if centerEnabled {
                return "알림센터만 켜짐: 배너는 꺼져 있습니다."
            }

            return "권한 있음, 하지만 배너/알림센터 표시가 꺼져 있습니다."
        @unknown default:
            return "알림 상태를 확인할 수 없습니다."
        }
    }

    public func makeBootstrapNotificationRequest(
        identifier: String = MessageNotificationAuthorizationPlan.bootstrapNotificationIdentifier,
        deliveryDelay: TimeInterval = 1
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "우주사과 알림 준비"
        content.body = "이 알림이 알림센터에 보이면 시스템 설정에서 배너를 켤 수 있습니다."

        return UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: deliveryDelay, repeats: false)
        )
    }
}
