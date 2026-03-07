import Foundation
import Combine

class NtfySubscriber: ObservableObject {
    @Published var connectionStatus: String = "Disconnected"
    @Published var lastMessage: String = "No messages yet"

    private var urlSession: URLSession?
    private var dataTask: URLSessionDataTask?
    
    func subscribe(server: String, topic: String) {
        guard !topic.isEmpty else { return }
        
        let urlString = "\(server)/\(topic)/json"
        guard let url = URL(string: urlString) else { return }
        
        connectionStatus = "Connecting..."
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(Double.infinity)
        configuration.timeoutIntervalForResource = TimeInterval(Double.infinity)
        
        urlSession = URLSession(configuration: configuration, delegate: SessionDelegate(onMessage: { [weak self] jsonString in
            self?.handleIncomingMessage(jsonString)
        }), delegateQueue: nil)
        
        dataTask = urlSession?.dataTask(with: url)
        dataTask?.resume()
        
        connectionStatus = "Subscribed: \(topic)"
    }
    
    private func handleIncomingMessage(_ jsonString: String) {
        guard let data = jsonString.data(using: .utf8) else { return }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let messageBody = json["message"] as? String {
                
                // ntfy.sh returns the published payload in the "message" field of its SSE JSON
                // If we published a JSON string, we need to parse it again
                if let payloadData = messageBody.data(using: .utf8),
                   let payload = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any] {
                    
                    let title = payload["title"] as? String ?? "New Message"
                    let body = payload["body"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self.lastMessage = "\(title): \(body)"
                        NotificationManager.shared.show(title: title, body: body)
                    }
                }
            }
        } catch {
            print("Error parsing ntfy message: \(error)")
        }
    }
    
    func disconnect() {
        dataTask?.cancel()
        connectionStatus = "Disconnected"
    }
}

// Simple delegate to handle streaming data line by line
class SessionDelegate: NSObject, URLSessionDataDelegate {
    let onMessage: (String) -> Void
    private var buffer = Data()

    init(onMessage: @escaping (String) -> Void) {
        self.onMessage = onMessage
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        buffer.append(data)
        
        while let range = buffer.range(of: Data("\n".utf8)) {
            let lineData = buffer.subdata(in: 0..<range.lowerBound)
            buffer.removeSubrange(0..<range.upperBound)
            
            if let line = String(data: lineData, encoding: .utf8), !line.trimmingCharacters(in: .whitespaces).isEmpty {
                onMessage(line)
            }
        }
    }
}
