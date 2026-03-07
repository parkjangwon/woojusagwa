import Foundation

public enum PairingPayloadError: Error {
    case blankTopic
}

public struct PairingPayload: Codable, Equatable {
    public let version: Int
    public let server: String
    public let topic: String

    public init(
        topic: String,
        server: String = "https://ntfy.sh",
        version: Int = 1
    ) throws {
        let normalizedTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTopic.isEmpty else {
            throw PairingPayloadError.blankTopic
        }

        self.version = version
        self.server = server
        self.topic = normalizedTopic
    }

    public func encodedJSONString() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}
