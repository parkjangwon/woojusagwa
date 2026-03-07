import XCTest
@testable import WoojusagwaCore

final class PairingPayloadTests: XCTestCase {
    func testEncodesDefaultPairingPayload() throws {
        let payload = try PairingPayload(topic: "ws_apple")
        let json = try payload.encodedJSONString()

        XCTAssertTrue(json.contains("\"version\":1"))
        XCTAssertTrue(json.contains("\"server\":\"https://ntfy.sh\""))
        XCTAssertTrue(json.contains("\"topic\":\"ws_apple\""))
    }

    func testRejectsBlankTopic() {
        XCTAssertThrowsError(try PairingPayload(topic: "   ")) { error in
            XCTAssertEqual(error as? PairingPayloadError, .blankTopic)
        }
    }
}
