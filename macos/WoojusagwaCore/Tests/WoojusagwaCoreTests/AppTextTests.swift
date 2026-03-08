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
            AppText.versionLabel(version: "2.3.4", build: "2003004", languageCode: "ko-KR"),
            "버전 2.3.4 (2003004)"
        )
        XCTAssertEqual(
            AppText.versionLabel(version: "2.3.4", build: "2003004", languageCode: "en-US"),
            "Version 2.3.4 (2003004)"
        )
    }
}
