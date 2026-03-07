import XCTest
@testable import WoojusagwaCore

final class AppTextTests: XCTestCase {
    func testFallsBackToKoreanWhenLanguageIsNotEnglish() {
        XCTAssertEqual(
            AppText.pick(ko: "연결된 Mac", en: "Paired Macs", languageCode: "ja-JP"),
            "연결된 Mac"
        )
    }

    func testUsesEnglishWhenLanguageCodeStartsWithEnglish() {
        XCTAssertEqual(
            AppText.pick(ko: "연결된 Mac", en: "Paired Macs", languageCode: "en-US"),
            "Paired Macs"
        )
    }

    func testFormatsVersionLabelPerLanguage() {
        XCTAssertEqual(
            AppText.versionLabel(version: "0.0.9", build: "9", languageCode: "ko-KR"),
            "버전 0.0.9 (9)"
        )
        XCTAssertEqual(
            AppText.versionLabel(version: "0.0.9", build: "9", languageCode: "en-US"),
            "Version 0.0.9 (9)"
        )
    }
}
