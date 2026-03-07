import XCTest
@testable import WoojusagwaCore

final class MenuBarSummaryTests: XCTestCase {
    func testBuildsThreeSectionsWithoutLastMessage() {
        let summary = MenuBarSummary.make(
            deviceName: "개인 MacBook Pro",
            deviceId: "mac-home",
            topic: "ws_home",
            notificationStatus: "알림 허용됨",
            languageCode: "ko-KR"
        )

        XCTAssertEqual(summary.sections.map(\.kind), [.status, .device, .topic])
        XCTAssertEqual(summary.sections.count, 3)
    }

    func testUsesNotPairedPlaceholderForBlankTopic() {
        let summary = MenuBarSummary.make(
            deviceName: "Work MacBook Air",
            deviceId: "mac-work",
            topic: "   ",
            notificationStatus: "Notification allowed",
            languageCode: "en-US"
        )

        XCTAssertEqual(summary.sections[2].primaryText, "Not paired yet")
    }

    func testLocalizesEnglishSectionLabels() {
        let summary = MenuBarSummary.make(
            deviceName: "Work MacBook Air",
            deviceId: "mac-work",
            topic: "ws_work",
            notificationStatus: "Notification allowed",
            languageCode: "en-US"
        )

        XCTAssertEqual(summary.title, "Woojusagwa")
        XCTAssertEqual(summary.sections[0].title, "Notification Status")
        XCTAssertEqual(summary.sections[1].title, "This Mac")
        XCTAssertEqual(summary.sections[2].title, "Current Topic")
    }
}
