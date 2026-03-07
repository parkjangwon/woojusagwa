import Testing
@testable import WoojusagwaCore

struct RelayEnvelopeTests {
    @Test
    func decodesRelayMessageFromNtfyEnvelope() throws {
        let line = #"{"message":"{\"title\":\"Alice\",\"body\":\"Landing in 10\"}"}"#
        let payload = try RelayEnvelopeDecoder().decode(line: line)

        #expect(payload.title == "Alice")
        #expect(payload.body == "Landing in 10")
    }

    @Test
    func rejectsMalformedEnvelope() {
        #expect(throws: RelayEnvelopeError.self) {
            _ = try RelayEnvelopeDecoder().decode(line: "not json")
        }
    }

    @Test
    func rejectsEnvelopeWithoutMessagePayload() {
        #expect(throws: RelayEnvelopeError.self) {
            _ = try RelayEnvelopeDecoder().decode(line: #"{"event":"keepalive"}"#)
        }
    }
}
