import XCTest
import UserNotifications
@testable import WoojusagwaCore

final class MessageNotificationTests: XCTestCase {
    func testBuildsImmediateRequestWithIncomingMessageContent() {
        let request = MessageNotificationRequestFactory().makeRequest(title: "Alice", body: "Landing in 10")

        XCTAssertEqual(request.content.title, "Alice")
        XCTAssertEqual(request.content.body, "Landing in 10")
        XCTAssertNil(request.trigger)
    }

    func testForegroundPresentationUsesBannerListAndSound() {
        let options = MessageNotificationRequestFactory().foregroundPresentationOptions

        XCTAssertTrue(options.contains(.banner))
        XCTAssertTrue(options.contains(.list))
        XCTAssertTrue(options.contains(.sound))
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
