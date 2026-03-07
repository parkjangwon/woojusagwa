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
            AppText.versionLabel(version: "1.0.0", build: "100", languageCode: "ko-KR"),
            "버전 1.0.0 (100)"
        )
        XCTAssertEqual(
            AppText.versionLabel(version: "1.0.0", build: "100", languageCode: "en-US"),
            "Version 1.0.0 (100)"
        )
    }
}
