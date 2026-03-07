import Foundation
import Testing
@testable import WoojusagwaCore

struct PairingConfigurationStoreTests {
    @Test
    func savesAndLoadsPayload() throws {
        let defaults = try #require(UserDefaults(suiteName: "WoojusagwaCoreTests.\(UUID().uuidString)"))
        let store = PairingConfigurationStore(defaults: defaults)
        let payload = try PairingPayload(topic: "ws_saved", server: "https://relay.example")

        try store.save(payload)
        let restored = try store.load()

        #expect(restored == payload)
    }

    @Test
    func returnsNilWhenNothingWasSaved() throws {
        let defaults = try #require(UserDefaults(suiteName: "WoojusagwaCoreTests.\(UUID().uuidString)"))
        let store = PairingConfigurationStore(defaults: defaults)

        #expect(try store.load() == nil)
    }
}
