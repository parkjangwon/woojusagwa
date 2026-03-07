import XCTest
import UserNotifications
@testable import WoojusagwaCore

final class MessageNotificationTests: XCTestCase {
    func testBuildsScheduledRequestWithIncomingMessageContent() throws {
        let request = MessageNotificationRequestFactory().makeRequest(title: "Alice", body: "Landing in 10")

        XCTAssertEqual(request.content.title, "Alice")
        XCTAssertEqual(request.content.body, "Landing in 10")
        let trigger = try XCTUnwrap(request.trigger as? UNTimeIntervalNotificationTrigger)
        XCTAssertEqual(trigger.timeInterval, 1, accuracy: 0.01)
        XCTAssertFalse(trigger.repeats)
    }

    func testForegroundPresentationUsesBannerListAndSound() {
        let options = MessageNotificationRequestFactory().foregroundPresentationOptions

        XCTAssertTrue(options.contains(.banner))
        XCTAssertTrue(options.contains(.list))
        XCTAssertTrue(options.contains(.sound))
    }

    func testBootstrapAuthorizationRequestIncludesProvisionalRegistration() {
        let options = MessageNotificationAuthorizationPlan().bootstrapRequestOptions

        XCTAssertTrue(options.contains(.alert))
        XCTAssertTrue(options.contains(.sound))
        XCTAssertTrue(options.contains(.badge))
        XCTAssertTrue(options.contains(.provisional))
        XCTAssertTrue(options.contains(.providesAppNotificationSettings))
    }

    func testStatusTextForProvisionalAuthorizationExplainsQuietDelivery() {
        let statusText = MessageNotificationAuthorizationPlan().statusText(
            authorizationStatus: .provisional,
            alertSetting: .disabled,
            notificationCenterSetting: .enabled
        )

        XCTAssertEqual(statusText, "임시 허용됨: 알림센터에 조용히 전달됩니다. 테스트 알림 후 유지 또는 즉시 전달로 바꿔 주세요.")
    }

    func testBuildsQuietBootstrapNotificationRequest() throws {
        let request = MessageNotificationAuthorizationPlan().makeBootstrapNotificationRequest()

        XCTAssertEqual(request.identifier, MessageNotificationAuthorizationPlan.bootstrapNotificationIdentifier)
        XCTAssertEqual(request.content.title, "우주사과 알림 준비")
        XCTAssertEqual(request.content.body, "이 알림이 알림센터에 보이면 시스템 설정에서 배너를 켤 수 있습니다.")
        XCTAssertNil(request.content.sound)
        let trigger = try XCTUnwrap(request.trigger as? UNTimeIntervalNotificationTrigger)
        XCTAssertEqual(trigger.timeInterval, 1, accuracy: 0.01)
        XCTAssertFalse(trigger.repeats)
    }

    func testAddsCopyActionWhenOtpCodeIsDetected() {
        let request = MessageNotificationRequestFactory().makeRequest(
            title: "토스",
            body: "인증번호는 123456입니다. 화면에 입력해 주세요."
        )

        XCTAssertEqual(request.content.categoryIdentifier, MessageNotificationAction.categoryIdentifier)
        XCTAssertEqual(request.content.userInfo[MessageNotificationAction.otpCodeUserInfoKey] as? String, "123456")
    }

    func testLeavesRegularMessagesWithoutOtpCopyAction() {
        let request = MessageNotificationRequestFactory().makeRequest(
            title: "Alice",
            body: "Call me when you arrive at gate 1234."
        )

        XCTAssertEqual(request.content.categoryIdentifier, "")
        XCTAssertNil(request.content.userInfo[MessageNotificationAction.otpCodeUserInfoKey])
    }

    func testAddsCopyActionWhenJapaneseOtpCodeIsDetected() {
        let request = MessageNotificationRequestFactory().makeRequest(
            title: "楽天",
            body: "認証コードは123456です。画面に入力してください。"
        )

        XCTAssertEqual(request.content.categoryIdentifier, MessageNotificationAction.categoryIdentifier)
        XCTAssertEqual(request.content.userInfo[MessageNotificationAction.otpCodeUserInfoKey] as? String, "123456")
    }

    func testAddsCopyActionWhenSimplifiedChineseOtpCodeIsDetected() {
        let request = MessageNotificationRequestFactory().makeRequest(
            title: "支付宝",
            body: "您的验证码是123456，请在页面中输入。"
        )

        XCTAssertEqual(request.content.categoryIdentifier, MessageNotificationAction.categoryIdentifier)
        XCTAssertEqual(request.content.userInfo[MessageNotificationAction.otpCodeUserInfoKey] as? String, "123456")
    }

    func testAddsCopyActionWhenTraditionalChineseOtpCodeIsDetected() {
        let request = MessageNotificationRequestFactory().makeRequest(
            title: "銀行",
            body: "您的驗證碼為123456，請勿透露給他人。"
        )

        XCTAssertEqual(request.content.categoryIdentifier, MessageNotificationAction.categoryIdentifier)
        XCTAssertEqual(request.content.userInfo[MessageNotificationAction.otpCodeUserInfoKey] as? String, "123456")
    }
}
