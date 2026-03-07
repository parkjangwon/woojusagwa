import Foundation

public enum PairingConfigurationStoreError: Error {
    case invalidEncoding
}

public final class PairingConfigurationStore {
    private let defaults: UserDefaults
    private let key: String

    public init(
        defaults: UserDefaults = .standard,
        key: String = "woojusagwa.pairingPayload"
    ) {
        self.defaults = defaults
        self.key = key
    }

    public func save(_ payload: PairingPayload) throws {
        let data = try JSONEncoder().encode(payload)
        defaults.set(data, forKey: key)
    }

    public func load() throws -> PairingPayload? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }

        return try JSONDecoder().decode(PairingPayload.self, from: data)
    }

    public func clear() {
        defaults.removeObject(forKey: key)
    }
}
