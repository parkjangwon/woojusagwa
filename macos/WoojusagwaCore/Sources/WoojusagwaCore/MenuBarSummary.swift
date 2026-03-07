import Foundation

public struct MenuBarSummary: Equatable {
    public struct Section: Identifiable, Equatable {
        public enum Kind: String, Equatable {
            case status
            case device
            case topic
        }

        public enum TextStyle: Equatable {
            case body
            case monospaced
        }

        public let kind: Kind
        public let title: String
        public let primaryText: String
        public let secondaryText: String?
        public let primaryStyle: TextStyle
        public let secondaryStyle: TextStyle?
        public let usesMiddleTruncation: Bool

        public var id: String {
            kind.rawValue
        }
    }

    public let title: String
    public let subtitle: String
    public let footnote: String
    public let sections: [Section]

    public static func make(
        deviceName: String,
        deviceId: String,
        topic: String,
        notificationStatus: String,
        languageCode: String? = nil
    ) -> MenuBarSummary {
        let trimmedTopic = topic.trimmingCharacters(in: .whitespacesAndNewlines)
        let localizedTopic = trimmedTopic.isEmpty
            ? AppText.pick(
                ko: "아직 페어링되지 않음",
                en: "Not paired yet",
                languageCode: languageCode
            )
            : trimmedTopic

        return MenuBarSummary(
            title: AppText.pick(
                ko: "우주사과",
                en: "Woojusagwa",
                languageCode: languageCode
            ),
            subtitle: AppText.pick(
                ko: "Galaxy SMS를 여러 Mac 알림으로 이어줍니다",
                en: "Galaxy SMS forwarded to your Macs",
                languageCode: languageCode
            ),
            footnote: AppText.pick(
                ko: "각 Mac은 고유 토픽으로 연결되고, 알림은 macOS 알림센터에 표시됩니다.",
                en: "Each Mac uses its own private topic and shows native macOS notifications.",
                languageCode: languageCode
            ),
            sections: [
                Section(
                    kind: .status,
                    title: AppText.pick(
                        ko: "알림 상태",
                        en: "Notification Status",
                        languageCode: languageCode
                    ),
                    primaryText: notificationStatus,
                    secondaryText: nil,
                    primaryStyle: .body,
                    secondaryStyle: nil,
                    usesMiddleTruncation: false
                ),
                Section(
                    kind: .device,
                    title: AppText.pick(
                        ko: "이 Mac",
                        en: "This Mac",
                        languageCode: languageCode
                    ),
                    primaryText: deviceName,
                    secondaryText: AppText.pick(
                        ko: "ID",
                        en: "ID",
                        languageCode: languageCode
                    ) + ": \(deviceId)",
                    primaryStyle: .body,
                    secondaryStyle: .monospaced,
                    usesMiddleTruncation: true
                ),
                Section(
                    kind: .topic,
                    title: AppText.pick(
                        ko: "현재 토픽",
                        en: "Current Topic",
                        languageCode: languageCode
                    ),
                    primaryText: localizedTopic,
                    secondaryText: nil,
                    primaryStyle: .monospaced,
                    secondaryStyle: nil,
                    usesMiddleTruncation: true
                ),
            ]
        )
    }
}
