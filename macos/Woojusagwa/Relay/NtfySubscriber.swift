import Foundation
import Combine
import AppKit

final class NtfySubscriber: ObservableObject {
    @Published private(set) var connectionStatus: String
    @Published private(set) var lastMessage: String
    @Published private(set) var topicLabel: String
    @Published private(set) var notificationAuthorizationStatus: String

    private var urlSession: URLSession?
    private var dataTask: URLSessionDataTask?
    private let pairingStore: PairingConfigurationStore
    private let notificationManager: NotificationManager
    private let relayDecoder = RelayEnvelopeDecoder()
    private var cancellables = Set<AnyCancellable>()

    init(
        pairingStore: PairingConfigurationStore,
        notificationManager: NotificationManager
    ) {
        self.pairingStore = pairingStore
        self.notificationManager = notificationManager
        self.connectionStatus = "Ready to pair"
        self.lastMessage = "No messages yet"
        self.topicLabel = "Not paired"
        self.notificationAuthorizationStatus = notificationManager.authorizationStatusText

        notificationManager.$authorizationStatusText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] statusText in
                self?.notificationAuthorizationStatus = statusText
            }
            .store(in: &cancellables)

        restorePairingIfAvailable()
    }
    
    func prepareFreshPairingPayload() throws -> String {
        let payload = try PairingPayload(topic: makeTopic())
        try connect(using: payload)
        return try payload.encodedJSONString()
    }

    func copyLastMessage() {
        guard !lastMessage.isEmpty, lastMessage != "No messages yet" else {
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
        connectionStatus = "Disconnected"
    }

    func sendTestNotification() {
        notificationManager.sendTestNotification()
    }

    func requestNotificationAuthorization() {
        notificationManager.requestNotificationAuthorization()
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
        
        connectionStatus = "Connecting..."
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(Double.infinity)
        configuration.timeoutIntervalForResource = TimeInterval(Double.infinity)
        
        urlSession = URLSession(configuration: configuration, delegate: SessionDelegate(onLine: { [weak self] line in
            self?.handleIncomingLine(line)
        }), delegateQueue: nil)
        
        dataTask = urlSession?.dataTask(with: url)
        dataTask?.resume()
        
        connectionStatus = "Listening on ntfy"
    }
    
    private func handleIncomingLine(_ line: String) {
        do {
            let payload = try relayDecoder.decode(line: line)
            let summary = "\(payload.title): \(payload.body)"

            DispatchQueue.main.async {
                self.lastMessage = summary
                self.connectionStatus = "Receiving messages"
                self.notificationManager.show(title: payload.title, body: payload.body)
            }
        } catch {
            guard let relayError = error as? RelayEnvelopeError else {
                connectionStatus = "Relay error"
                return
            }

            switch relayError {
            case .invalidEnvelope, .missingMessage:
                break
            case .invalidPayload:
                connectionStatus = "Relay payload error"
            }
        }
    }

    private func makeTopic() -> String {
        let raw = UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased()
        return "ws_\(raw.prefix(12))"
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
