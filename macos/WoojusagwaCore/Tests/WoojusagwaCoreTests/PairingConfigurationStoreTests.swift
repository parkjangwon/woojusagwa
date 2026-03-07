import Foundation
import XCTest
@testable import WoojusagwaCore

final class PairingConfigurationStoreTests: XCTestCase {
    func testSavesAndLoadsPayload() throws {
        let suiteName = "WoojusagwaCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected dedicated UserDefaults suite")
            return
        }

        let store = PairingConfigurationStore(defaults: defaults)
        let payload = try PairingPayload(topic: "ws_saved", server: "https://relay.example")

        try store.save(payload)
        let restored = try store.load()

        XCTAssertEqual(restored, payload)
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testReturnsNilWhenNothingWasSaved() throws {
        let suiteName = "WoojusagwaCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected dedicated UserDefaults suite")
            return
        }

        let store = PairingConfigurationStore(defaults: defaults)

        XCTAssertNil(try store.load())
        defaults.removePersistentDomain(forName: suiteName)
    }
}
