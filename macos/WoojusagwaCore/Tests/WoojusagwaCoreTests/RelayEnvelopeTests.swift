import XCTest
@testable import WoojusagwaCore

final class RelayEnvelopeTests: XCTestCase {
    func testDecodesRelayMessageFromNtfyEnvelope() throws {
        let line = #"{"message":"{\"title\":\"Alice\",\"body\":\"Landing in 10\"}"}"#
        let payload = try RelayEnvelopeDecoder().decode(line: line)

        XCTAssertEqual(payload.title, "Alice")
        XCTAssertEqual(payload.body, "Landing in 10")
    }

    func testRejectsMalformedEnvelope() {
        XCTAssertThrowsError(try RelayEnvelopeDecoder().decode(line: "not json")) { error in
            XCTAssertEqual(error as? RelayEnvelopeError, .invalidEnvelope)
        }
    }

    func testRejectsEnvelopeWithoutMessagePayload() {
        XCTAssertThrowsError(try RelayEnvelopeDecoder().decode(line: #"{"event":"keepalive"}"#)) { error in
            XCTAssertEqual(error as? RelayEnvelopeError, .missingMessage)
        }
    }
}
