import Foundation

public enum AppLanguage: String, CaseIterable, Identifiable {
    case korean = "ko"
    case english = "en"

    public var id: String {
        rawValue
    }

    public var tag: String {
        rawValue
    }

    public var displayName: String {
        switch self {
        case .korean:
            return "한국어"
        case .english:
            return "English"
        }
    }

    public static func resolve(languageCode: String?) -> AppLanguage {
        let normalized = languageCode?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? AppLanguage.korean.rawValue

        if normalized.hasPrefix(AppLanguage.english.rawValue) {
            return .english
        }

        return .korean
    }
}

public final class AppLanguageStore {
    private let defaults: UserDefaults
    private let key: String

    public init(
        defaults: UserDefaults = .standard,
        key: String = "app_language"
    ) {
        self.defaults = defaults
        self.key = key
    }

    public func currentLanguage() -> AppLanguage {
        AppLanguage.resolve(languageCode: defaults.string(forKey: key))
    }

    public func setLanguage(_ language: AppLanguage) {
        defaults.set(language.rawValue, forKey: key)
    }
}

public enum AppText {
    public static var preferredLanguageCodeProvider: () -> String = {
        Locale.preferredLanguages.first ?? AppLanguage.korean.rawValue
    }

    public static func pick(
        ko: String,
        en: String,
        languageCode: String? = nil
    ) -> String {
        if AppLanguage.resolve(languageCode: languageCode ?? preferredLanguageCodeProvider()) == .english {
            return en
        }

        return ko
    }

    public static func versionLabel(
        version: String,
        build: String,
        languageCode: String? = nil
    ) -> String {
        pick(
            ko: "버전 \(version) (\(build))",
            en: "Version \(version) (\(build))",
            languageCode: languageCode
        )
    }
}
