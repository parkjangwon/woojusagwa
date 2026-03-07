import XCTest
@testable import WoojusagwaCore

final class PairingPayloadTests: XCTestCase {
    func testEncodesDefaultPairingPayloadWithDeviceMetadata() throws {
        let payload = try PairingPayload(
            topic: "ws_apple",
            deviceId: "mac-123",
            deviceName: "개인 MacBook Pro"
        )
        let json = try payload.encodedJSONString()

        XCTAssertTrue(json.contains("\"version\":2"))
        XCTAssertTrue(json.contains("\"server\":\"https://ntfy.sh\""))
        XCTAssertTrue(json.contains("\"topic\":\"ws_apple\""))
        XCTAssertTrue(json.contains("\"device_id\":\"mac-123\""))
        XCTAssertTrue(json.contains("\"device_name\":\"개인 MacBook Pro\""))
    }

    func testRejectsBlankTopic() {
        XCTAssertThrowsError(try PairingPayload(topic: "   ", deviceId: "mac-123", deviceName: "개인 MacBook Pro")) { error in
            XCTAssertEqual(error as? PairingPayloadError, .blankTopic)
        }
    }
}
