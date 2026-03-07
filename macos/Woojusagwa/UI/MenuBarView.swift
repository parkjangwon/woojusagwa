import SwiftUI
import CoreImage.CIFilterBuiltins

struct MenuBarView: View {
    @ObservedObject var subscriber: NtfySubscriber
    @State private var showingQR = false
    @State private var pairingPayload = ""
    
    var body: some View {
        VStack(spacing: 12) {
            Text("우주사과 (woojusagwa)")
                .font(.headline)
            
            Divider()
            
            HStack {
                Circle()
                    .fill(subscriber.connectionStatus.contains("Subscribed") ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(subscriber.connectionStatus)
                    .font(.subheadline)
            }
            
            Button("Show Pairing QR") {
                generatePairingPayload()
                showingQR.toggle()
            }
            .buttonStyle(.borderedProminent)
            
            if showingQR {
                Image(uiImage: generateQRCode(from: pairingPayload))
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding()
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding()
        .frame(width: 250)
    }
    
    func generatePairingPayload() {
        // Topic usually generated once or on-demand
        let topic = "ws_\(UUID().uuidString.prefix(8).lowercased())"
        let payload = "{"version":1,"server":"https://ntfy.sh","topic":"\(topic)"}"
        self.pairingPayload = payload
        
        // Auto-subscribe to the new topic
        subscriber.subscribe(server: "https://ntfy.sh", topic: topic)
    }
    
    func generateQRCode(from string: String) -> NSImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return NSImage(cgImage: cgimg, size: NSSize(width: 150, height: 150))
            }
        }
        return NSImage()
    }
}
