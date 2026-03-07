import Foundation

public struct DeviceIdentity: Equatable {
    public let deviceId: String
    public let deviceName: String

    public init(deviceId: String, deviceName: String) {
        self.deviceId = deviceId
        self.deviceName = deviceName
    }
}

public final class DeviceIdentityStore {
    private let defaults: UserDefaults
    private let key: String
    private let idGenerator: () -> String
    private let nameProvider: () -> String

    public init(
        defaults: UserDefaults = .standard,
        key: String = "woojusagwa.deviceId",
        idGenerator: @escaping () -> String = { UUID().uuidString.lowercased() },
        nameProvider: @escaping () -> String = {
            Host.current().localizedName ?? ProcessInfo.processInfo.hostName
        }
    ) {
        self.defaults = defaults
        self.key = key
        self.idGenerator = idGenerator
        self.nameProvider = nameProvider
    }

    public func currentIdentity() -> DeviceIdentity {
        let deviceId = storedOrGeneratedDeviceId()
        let rawName = nameProvider().trimmingCharacters(in: .whitespacesAndNewlines)
        let deviceName = rawName.isEmpty ? "Mac" : rawName

        return DeviceIdentity(deviceId: deviceId, deviceName: deviceName)
    }

    private func storedOrGeneratedDeviceId() -> String {
        if let stored = defaults.string(forKey: key)?.trimmingCharacters(in: .whitespacesAndNewlines),
           !stored.isEmpty {
            return stored
        }

        let generated = idGenerator().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized = generated.isEmpty ? UUID().uuidString.lowercased() : generated
        defaults.set(normalized, forKey: key)
        return normalized
    }
}
