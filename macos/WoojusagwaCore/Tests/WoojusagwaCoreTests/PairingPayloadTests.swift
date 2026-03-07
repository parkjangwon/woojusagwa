import Foundation
import Testing
@testable import WoojusagwaCore

struct PairingPayloadTests {
    @Test
    func encodesDefaultPairingPayload() throws {
        let payload = try PairingPayload(topic: "ws_apple")
        let json = try payload.encodedJSONString()

        #expect(json.contains("\"version\":1"))
        #expect(json.contains("\"server\":\"https://ntfy.sh\""))
        #expect(json.contains("\"topic\":\"ws_apple\""))
    }

    @Test
    func rejectsBlankTopic() {
        #expect(throws: PairingPayloadError.self) {
            _ = try PairingPayload(topic: "   ")
        }
    }
}
