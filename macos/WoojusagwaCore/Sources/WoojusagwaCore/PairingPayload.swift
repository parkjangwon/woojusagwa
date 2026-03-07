import Foundation

public enum PairingPayloadError: Error {
    case blankTopic
    case blankDeviceId
    case blankDeviceName
}

public struct PairingPayload: Codable, Equatable {
    public let version: Int
    public let server: String
    public let topic: String
    public let deviceId: String
    public let deviceName: String

    private enum CodingKeys: String, CodingKey {
        case version
        case server
        case topic
        case deviceId = "device_id"
        case deviceName = "device_name"
        case legacyDeviceId = "deviceId"
        case legacyDeviceName = "deviceName"
    }

    public init(
        topic: String,
        server: String = "https://ntfy.sh",
        deviceId: String,
        deviceName: String,
        version: Int = 2
    ) throws {
        let normalizedTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDeviceId = deviceId.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDeviceName = deviceName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedTopic.isEmpty else {
            throw PairingPayloadError.blankTopic
        }
        guard !normalizedDeviceId.isEmpty else {
            throw PairingPayloadError.blankDeviceId
        }
        guard !normalizedDeviceName.isEmpty else {
            throw PairingPayloadError.blankDeviceName
        }

        self.version = version
        self.server = server
        self.topic = normalizedTopic
        self.deviceId = normalizedDeviceId
        self.deviceName = normalizedDeviceName
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        version = try container.decode(Int.self, forKey: .version)
        server = try container.decode(String.self, forKey: .server)
        topic = try container.decode(String.self, forKey: .topic)
        deviceId = try container.decodeIfPresent(String.self, forKey: .deviceId)
            ?? container.decodeIfPresent(String.self, forKey: .legacyDeviceId)
            ?? ""
        deviceName = try container.decodeIfPresent(String.self, forKey: .deviceName)
            ?? container.decodeIfPresent(String.self, forKey: .legacyDeviceName)
            ?? ""
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(version, forKey: .version)
        try container.encode(server, forKey: .server)
        try container.encode(topic, forKey: .topic)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(deviceName, forKey: .deviceName)
    }

    public func encodedJSONString() throws -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        let data = try encoder.encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}
