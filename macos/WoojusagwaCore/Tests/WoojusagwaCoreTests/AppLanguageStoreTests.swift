import XCTest
@testable import WoojusagwaCore

final class AppLanguageStoreTests: XCTestCase {
    func testDefaultsToKorean() {
        let suiteName = "WoojusagwaCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected dedicated UserDefaults suite")
            return
        }

        let store = AppLanguageStore(defaults: defaults)

        XCTAssertEqual(store.currentLanguage(), .korean)
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testPersistsEnglishSelection() {
        let suiteName = "WoojusagwaCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected dedicated UserDefaults suite")
            return
        }

        let store = AppLanguageStore(defaults: defaults)
        store.setLanguage(.english)

        XCTAssertEqual(store.currentLanguage(), .english)
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testFallsBackToKoreanForUnsupportedLanguageCode() {
        let suiteName = "WoojusagwaCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected dedicated UserDefaults suite")
            return
        }

        defaults.set("fr", forKey: "app_language")
        let store = AppLanguageStore(defaults: defaults)

        XCTAssertEqual(store.currentLanguage(), .korean)
        defaults.removePersistentDomain(forName: suiteName)
    }
}
