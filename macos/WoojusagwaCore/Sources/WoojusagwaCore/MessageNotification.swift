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

    public init(codeDetector: OneTimeCodeDetector = OneTimeCodeDetector()) {
        self.codeDetector = codeDetector
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
            trigger: nil
        )
    }
}
