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
        let payload = try PairingPayload(
            topic: "ws_saved",
            server: "https://relay.example",
            deviceId: "mac-123",
            deviceName: "회사 MacBook Air"
        )

        try store.save(payload)
        let restored = try store.load()

        XCTAssertEqual(restored, payload)
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testLoadsLegacyV1PayloadWithoutDeviceMetadata() throws {
        let suiteName = "WoojusagwaCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected dedicated UserDefaults suite")
            return
        }

        let store = PairingConfigurationStore(defaults: defaults)
        let legacyJSON = #"{"version":1,"server":"https://ntfy.sh","topic":"ws_saved"}"#
        defaults.set(Data(legacyJSON.utf8), forKey: "woojusagwa.pairingPayload")

        let restored = try store.load()

        XCTAssertEqual(restored?.version, 1)
        XCTAssertEqual(restored?.server, "https://ntfy.sh")
        XCTAssertEqual(restored?.topic, "ws_saved")
        XCTAssertEqual(restored?.deviceId, "")
        XCTAssertEqual(restored?.deviceName, "")
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
