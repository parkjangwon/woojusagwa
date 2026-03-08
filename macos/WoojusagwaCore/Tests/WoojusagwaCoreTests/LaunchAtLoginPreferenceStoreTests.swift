import XCTest
@testable import WoojusagwaCore

final class LaunchAtLoginPreferenceStoreTests: XCTestCase {
    func testDefaultsToDisabled() {
        let suiteName = "WoojusagwaCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected dedicated UserDefaults suite")
            return
        }

        let store = LaunchAtLoginPreferenceStore(defaults: defaults)

        XCTAssertFalse(store.isEnabled())
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testPersistsEnabledState() {
        let suiteName = "WoojusagwaCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected dedicated UserDefaults suite")
            return
        }

        let store = LaunchAtLoginPreferenceStore(defaults: defaults)
        store.setEnabled(true)

        XCTAssertTrue(store.isEnabled())
        defaults.removePersistentDomain(forName: suiteName)
    }
}
