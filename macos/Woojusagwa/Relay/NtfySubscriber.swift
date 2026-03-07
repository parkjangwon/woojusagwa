import Foundation
import Combine
import AppKit

enum SubscriberConnectionStatus {
    case readyToPair
    case disconnected
    case connecting
    case listening
    case receiving
    case relayError
    case relayPayloadError

    var localizedLabel: String {
        switch self {
        case .readyToPair:
            return AppText.pick(ko: "페어링 준비됨", en: "Ready to pair")
        case .disconnected:
            return AppText.pick(ko: "연결 해제됨", en: "Disconnected")
        case .connecting:
            return AppText.pick(ko: "연결 중", en: "Connecting")
        case .listening:
            return AppText.pick(ko: "ntfy 수신 대기 중", en: "Listening on ntfy")
        case .receiving:
            return AppText.pick(ko: "메시지 수신 중", en: "Receiving messages")
        case .relayError:
            return AppText.pick(ko: "릴레이 오류", en: "Relay error")
        case .relayPayloadError:
            return AppText.pick(ko: "릴레이 페이로드 오류", en: "Relay payload error")
        }
    }
}

final class NtfySubscriber: ObservableObject {
    @Published private(set) var connectionStatus: SubscriberConnectionStatus
    @Published private(set) var lastMessage: String
    @Published private(set) var topicLabel: String
    @Published private(set) var notificationAuthorizationStatus: String
    @Published private(set) var deviceNameLabel: String
    @Published private(set) var deviceIdLabel: String
    @Published private(set) var appVersionLabel: String

    private var urlSession: URLSession?
    private var dataTask: URLSessionDataTask?
    private let pairingStore: PairingConfigurationStore
    private let notificationManager: NotificationManager
    private let deviceIdentityStore: DeviceIdentityStore
    private let appVersionProvider: () -> String
    private let relayDecoder = RelayEnvelopeDecoder()
    private var cancellables = Set<AnyCancellable>()

    init(
        pairingStore: PairingConfigurationStore,
        notificationManager: NotificationManager,
        deviceIdentityStore: DeviceIdentityStore,
        appVersionProvider: @escaping () -> String = NtfySubscriber.defaultVersionLabel
    ) {
        let identity = deviceIdentityStore.currentIdentity()
        self.pairingStore = pairingStore
        self.notificationManager = notificationManager
        self.deviceIdentityStore = deviceIdentityStore
        self.appVersionProvider = appVersionProvider
        self.connectionStatus = .readyToPair
        self.lastMessage = ""
        self.topicLabel = ""
        self.notificationAuthorizationStatus = notificationManager.authorizationStatusText
        self.deviceNameLabel = identity.deviceName
        self.deviceIdLabel = identity.deviceId
        self.appVersionLabel = appVersionProvider()

        notificationManager.$authorizationStatusText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statusText in
                self?.notificationAuthorizationStatus = statusText
            }
            .store(in: &cancellables)

        restorePairingIfAvailable()
    }
    
    func prepareFreshPairingPayload() throws -> String {
        let identity = deviceIdentityStore.currentIdentity()
        let payload = try PairingPayload(
            topic: makeTopic(),
            deviceId: identity.deviceId,
            deviceName: identity.deviceName
        )
        try connect(using: payload)
        return try payload.encodedJSONString()
    }

    func copyLastMessage() {
        guard !lastMessage.isEmpty else {
            return
        }

        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(lastMessage, forType: .string)
    }

    func disconnect() {
        dataTask?.cancel()
        dataTask = nil
        urlSession?.invalidateAndCancel()
        urlSession = nil
        connectionStatus = .disconnected
    }

    func sendTestNotification() {
        notificationManager.sendTestNotification()
    }

    func requestNotificationAuthorization() {
        notificationManager.requestNotificationAuthorization()
    }

    func openNotificationSettings() {
        notificationManager.openNotificationSettings()
    }

    func refreshNotificationAuthorizationStatus() {
        notificationManager.refreshAuthorizationStatus()
    }

    private func connect(using payload: PairingPayload) throws {
        try pairingStore.save(payload)
        topicLabel = payload.topic
        subscribe(server: payload.server, topic: payload.topic)
    }

    private func restorePairingIfAvailable() {
        let identity = deviceIdentityStore.currentIdentity()
        deviceNameLabel = identity.deviceName
        deviceIdLabel = identity.deviceId
        appVersionLabel = appVersionProvider()

        guard let payload = try? pairingStore.load() else {
            return
        }

        topicLabel = payload.topic
        subscribe(server: payload.server, topic: payload.topic)
    }

    private func subscribe(server: String, topic: String) {
        guard !topic.isEmpty else { return }
        disconnect()

        let urlString = "\(server)/\(topic)/json"
        guard let url = URL(string: urlString) else { return }
        
        connectionStatus = .connecting
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(Double.infinity)
        configuration.timeoutIntervalForResource = TimeInterval(Double.infinity)
        
        urlSession = URLSession(configuration: configuration, delegate: SessionDelegate(onLine: { [weak self] line in
            self?.handleIncomingLine(line)
        }), delegateQueue: nil)
        
        dataTask = urlSession?.dataTask(with: url)
        dataTask?.resume()
        
        connectionStatus = .listening
    }
    
    private func handleIncomingLine(_ line: String) {
        do {
            let payload = try relayDecoder.decode(line: line)
            let summary = "\(payload.title): \(payload.body)"

            DispatchQueue.main.async {
                self.lastMessage = summary
                self.connectionStatus = .receiving
                self.notificationManager.show(title: payload.title, body: payload.body)
            }
        } catch {
            guard let relayError = error as? RelayEnvelopeError else {
                connectionStatus = .relayError
                return
            }

            switch relayError {
            case .invalidEnvelope, .missingMessage:
                break
            case .invalidPayload:
                connectionStatus = .relayPayloadError
            }
        }
    }

    private func makeTopic() -> String {
        let raw = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        return "ws_\(raw.prefix(12))"
    }

    private static func defaultVersionLabel() -> String {
        let infoDictionary = Bundle.main.infoDictionary
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return AppText.versionLabel(version: version, build: build)
    }
}

final class SessionDelegate: NSObject, URLSessionDataDelegate {
    let onLine: (String) -> Void
    private var buffer = Data()

    init(onLine: @escaping (String) -> Void) {
        self.onLine = onLine
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        
        while let range = buffer.range(of: Data("\n".utf8)) {
            let lineData = buffer.subdata(in: 0..<range.lowerBound)
            buffer.removeSubrange(0..<range.upperBound)
            
            if let line = String(data: lineData, encoding: .utf8), !line.trimmingCharacters(in: .whitespaces).isEmpty {
                onLine(line)
            }
        }
    }
}
