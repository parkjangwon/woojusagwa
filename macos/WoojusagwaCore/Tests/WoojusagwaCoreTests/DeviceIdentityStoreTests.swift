import XCTest
@testable import WoojusagwaCore

final class DeviceIdentityStoreTests: XCTestCase {
    func testCreatesDeviceIdentityOnceAndReusesIt() throws {
        let suiteName = "WoojusagwaCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected dedicated UserDefaults suite")
            return
        }

        let store = DeviceIdentityStore(
            defaults: defaults,
            idGenerator: { "mac-generated-123" },
            nameProvider: { "개인 MacBook Pro" }
        )

        let first = store.currentIdentity()
        let second = store.currentIdentity()

        XCTAssertEqual(first.deviceId, "mac-generated-123")
        XCTAssertEqual(first.deviceName, "개인 MacBook Pro")
        XCTAssertEqual(second, first)
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testFallsBackToGenericNameWhenProviderIsBlank() throws {
        let suiteName = "WoojusagwaCoreTests.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            XCTFail("Expected dedicated UserDefaults suite")
            return
        }

        let store = DeviceIdentityStore(
            defaults: defaults,
            idGenerator: { "mac-generated-123" },
            nameProvider: { "   " }
        )

        XCTAssertEqual(store.currentIdentity().deviceName, "Mac")
        defaults.removePersistentDomain(forName: suiteName)
    }
}
