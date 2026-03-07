import Foundation

public enum RelayEnvelopeError: Error {
    case invalidEnvelope
    case missingMessage
    case invalidPayload
}

public struct RelayMessagePayload: Codable, Equatable {
    public let title: String
    public let body: String

    public init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}

private struct RelayEnvelope: Decodable {
    let message: String?
}

public struct RelayEnvelopeDecoder {
    public init() {}

    public func decode(line: String) throws -> RelayMessagePayload {
        guard let envelopeData = line.data(using: .utf8) else {
            throw RelayEnvelopeError.invalidEnvelope
        }

        let envelope: RelayEnvelope
        do {
            envelope = try JSONDecoder().decode(RelayEnvelope.self, from: envelopeData)
        } catch {
            throw RelayEnvelopeError.invalidEnvelope
        }

        guard let message = envelope.message, let payloadData = message.data(using: .utf8) else {
            throw RelayEnvelopeError.missingMessage
        }

        do {
            return try JSONDecoder().decode(RelayMessagePayload.self, from: payloadData)
        } catch {
            throw RelayEnvelopeError.invalidPayload
        }
    }
}
