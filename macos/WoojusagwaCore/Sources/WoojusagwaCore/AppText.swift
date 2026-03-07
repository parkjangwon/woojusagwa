import Foundation

public enum AppText {
    public static var preferredLanguageCodeProvider: () -> String = {
        Locale.preferredLanguages.first ?? "ko"
    }

    public static func pick(
        ko: String,
        en: String,
        languageCode: String? = nil
    ) -> String {
        let resolvedLanguage = (languageCode ?? preferredLanguageCodeProvider())
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if resolvedLanguage.hasPrefix("en") {
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
