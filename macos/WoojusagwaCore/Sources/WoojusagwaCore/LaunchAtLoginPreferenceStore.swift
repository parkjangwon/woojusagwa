import Foundation

public final class LaunchAtLoginPreferenceStore {
    private let defaults: UserDefaults
    private let key: String

    public init(
        defaults: UserDefaults = .standard,
        key: String = "launch_at_login_enabled"
    ) {
        self.defaults = defaults
        self.key = key
    }

    public func isEnabled() -> Bool {
        defaults.bool(forKey: key)
    }

    public func setEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: key)
    }
}
